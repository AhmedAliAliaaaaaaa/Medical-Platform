from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.utils import timezone
from django.conf import settings
import json
import stripe

from .models import Payment, PaymentMethod, DoctorEarnings, WithdrawalRequest
from .forms import PaymentMethodForm, ConsultationPaymentForm, DoctorSubscriptionForm, WithdrawalRequestForm
from .payment_service import payment_service
from patients.models import MedicalCase
from doctors.models import Doctor

@login_required
def payment_methods(request):
    """Manage user payment methods"""
    user_payment_methods = PaymentMethod.objects.filter(user=request.user, is_active=True)
    
    if request.method == 'POST':
        form = PaymentMethodForm(request.POST)
        if form.is_valid():
            payment_method = form.save(commit=False)
            payment_method.user = request.user
            
            # If this is set as default, unset others
            if payment_method.is_default:
                PaymentMethod.objects.filter(user=request.user).update(is_default=False)
            
            payment_method.save()
            messages.success(request, 'تم إضافة طريقة الدفع بنجاح')
            return redirect('payments:payment_methods')
    else:
        form = PaymentMethodForm()
    
    context = {
        'form': form,
        'payment_methods': user_payment_methods,
    }
    return render(request, 'payments/payment_methods.html', context)

@login_required
def delete_payment_method(request, method_id):
    """Delete a payment method"""
    payment_method = get_object_or_404(PaymentMethod, id=method_id, user=request.user)
    payment_method.is_active = False
    payment_method.save()
    messages.success(request, 'تم حذف طريقة الدفع بنجاح')
    return redirect('payments:payment_methods')

@login_required
def consultation_payment(request, case_id):
    """Process consultation payment"""
    case = get_object_or_404(MedicalCase, id=case_id, patient__user=request.user)
    doctor = case.doctor
    
    if not doctor:
        messages.error(request, 'لم يتم تعيين طبيب لهذه الحالة')
        return redirect('patients:case_detail', case_id=case.id)
    
    # Check if payment already exists
    existing_payment = Payment.objects.filter(case=case, status__in=['completed', 'processing']).first()
    if existing_payment:
        messages.info(request, 'تم الدفع لهذه الاستشارة مسبقاً')
        return redirect('patients:case_detail', case_id=case.id)
    
    if request.method == 'POST':
        form = ConsultationPaymentForm(user=request.user, data=request.POST)
        if form.is_valid():
            payment_method = form.cleaned_data['payment_method']
            
            # Process payment
            result = payment_service.process_consultation_payment(
                patient=case.patient,
                doctor=doctor,
                case=case,
                amount=doctor.consultation_fee,
                payment_method=payment_method
            )
            
            if result['success']:
                if payment_method == 'stripe':
                    # Return client secret for Stripe
                    return JsonResponse({
                        'success': True,
                        'client_secret': result['client_secret'],
                        'payment_id': result['payment'].payment_id
                    })
                elif payment_method == 'paypal':
                    # Redirect to PayPal
                    return JsonResponse({
                        'success': True,
                        'approval_url': result['approval_url'],
                        'payment_id': result['payment'].payment_id
                    })
            else:
                return JsonResponse({
                    'success': False,
                    'error': result['error']
                })
    else:
        form = ConsultationPaymentForm(user=request.user)
    
    context = {
        'form': form,
        'case': case,
        'doctor': doctor,
        'amount': doctor.consultation_fee,
        'stripe_publishable_key': settings.STRIPE_PUBLISHABLE_KEY,
    }
    return render(request, 'payments/consultation_payment.html', context)

@csrf_exempt
@require_POST
def stripe_webhook(request):
    """Handle Stripe webhooks"""
    payload = request.body
    sig_header = request.META.get('HTTP_STRIPE_SIGNATURE')
    endpoint_secret = settings.STRIPE_WEBHOOK_SECRET
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, endpoint_secret
        )
    except ValueError:
        return JsonResponse({'error': 'Invalid payload'}, status=400)
    except stripe.error.SignatureVerificationError:
        return JsonResponse({'error': 'Invalid signature'}, status=400)
    
    # Handle the event
    if event['type'] == 'payment_intent.succeeded':
        payment_intent = event['data']['object']
        
        # Find the payment
        try:
            payment = Payment.objects.get(transaction_id=payment_intent['id'])
            payment.status = 'completed'
            payment.paid_at = timezone.now()
            payment.save()
            
            # Update case status
            if payment.case:
                payment.case.status = 'in_progress'
                payment.case.save()
            
            # Update doctor earnings
            if payment.doctor:
                earnings, created = DoctorEarnings.objects.get_or_create(doctor=payment.doctor)
                fee_breakdown = payment_service.calculate_platform_fee(payment.amount)
                earnings.total_earnings += fee_breakdown['doctor_amount']
                earnings.available_balance += fee_breakdown['doctor_amount']
                earnings.save()
                
        except Payment.DoesNotExist:
            pass
    
    return JsonResponse({'status': 'success'})

@login_required
def payment_success(request, payment_id):
    """Payment success page"""
    payment = get_object_or_404(Payment, payment_id=payment_id, user=request.user)
    
    context = {
        'payment': payment,
    }
    return render(request, 'payments/payment_success.html', context)

@login_required
def payment_cancel(request):
    """Payment cancelled page"""
    return render(request, 'payments/payment_cancel.html')

@login_required
def doctor_subscription(request):
    """Doctor subscription to payment methods"""
    if not hasattr(request.user, 'doctor'):
        messages.error(request, 'هذه الصفحة مخصصة للأطباء فقط')
        return redirect('core:home')
    
    if request.method == 'POST':
        form = DoctorSubscriptionForm(request.POST)
        if form.is_valid():
            # Process subscription payment
            subscription_type = form.cleaned_data['subscription_type']
            payment_method = form.cleaned_data['payment_method']
            
            # Define subscription amounts
            subscription_amounts = {
                'basic': 50,
                'premium': 100,
                'professional': 200,
            }
            
            amount = subscription_amounts[subscription_type]
            
            # Create subscription payment
            payment = Payment.objects.create(
                user=request.user,
                doctor=request.user.doctor,
                amount=amount,
                payment_purpose='subscription',
                description=f'اشتراك {dict(form.SUBSCRIPTION_TYPES)[subscription_type]}'
            )
            
            if payment_method == 'stripe':
                result = payment_service.create_stripe_payment_intent(
                    amount=amount,
                    metadata={
                        'payment_id': payment.payment_id,
                        'subscription_type': subscription_type,
                        'doctor_id': request.user.doctor.id
                    }
                )
                
                if result['success']:
                    payment.transaction_id = result['payment_intent_id']
                    payment.status = 'processing'
                    payment.save()
                    
                    return JsonResponse({
                        'success': True,
                        'client_secret': result['client_secret'],
                        'payment_id': payment.payment_id
                    })
                else:
                    payment.status = 'failed'
                    payment.save()
                    return JsonResponse({
                        'success': False,
                        'error': result['error']
                    })
            
            elif payment_method == 'paypal':
                result = payment_service.create_paypal_payment(
                    amount=amount,
                    description=f'Doctor Subscription - {subscription_type}'
                )
                
                if result['success']:
                    payment.transaction_id = result['payment_id']
                    payment.status = 'processing'
                    payment.save()
                    
                    return JsonResponse({
                        'success': True,
                        'approval_url': result['approval_url'],
                        'payment_id': payment.payment_id
                    })
                else:
                    payment.status = 'failed'
                    payment.save()
                    return JsonResponse({
                        'success': False,
                        'error': result['error']
                    })
    else:
        form = DoctorSubscriptionForm()
    
    context = {
        'form': form,
        'stripe_publishable_key': settings.STRIPE_PUBLISHABLE_KEY,
    }
    return render(request, 'payments/doctor_subscription.html', context)

@login_required
def doctor_earnings(request):
    """Doctor earnings dashboard"""
    if not hasattr(request.user, 'doctor'):
        messages.error(request, 'هذه الصفحة مخصصة للأطباء فقط')
        return redirect('core:home')
    
    earnings, created = DoctorEarnings.objects.get_or_create(doctor=request.user.doctor)
    recent_payments = Payment.objects.filter(
        doctor=request.user.doctor,
        status='completed'
    ).order_by('-paid_at')[:10]
    
    withdrawal_requests = WithdrawalRequest.objects.filter(
        doctor=request.user.doctor
    ).order_by('-requested_at')[:5]
    
    context = {
        'earnings': earnings,
        'recent_payments': recent_payments,
        'withdrawal_requests': withdrawal_requests,
    }
    return render(request, 'payments/doctor_earnings.html', context)

@login_required
def withdrawal_request(request):
    """Create withdrawal request"""
    if not hasattr(request.user, 'doctor'):
        messages.error(request, 'هذه الصفحة مخصصة للأطباء فقط')
        return redirect('core:home')
    
    earnings = get_object_or_404(DoctorEarnings, doctor=request.user.doctor)
    
    if request.method == 'POST':
        form = WithdrawalRequestForm(request.POST)
        if form.is_valid():
            amount = form.cleaned_data['amount']
            
            if amount > earnings.available_balance:
                messages.error(request, 'المبلغ المطلوب أكبر من الرصيد المتاح')
            else:
                withdrawal = WithdrawalRequest.objects.create(
                    doctor=request.user.doctor,
                    amount=amount,
                    bank_name=form.cleaned_data['bank_name'],
                    bank_account=form.cleaned_data['bank_account'],
                    account_holder_name=form.cleaned_data['account_holder_name']
                )
                
                # Update earnings
                earnings.available_balance -= amount
                earnings.pending_balance += amount
                earnings.save()
                
                messages.success(request, 'تم إرسال طلب السحب بنجاح')
                return redirect('payments:doctor_earnings')
    else:
        form = WithdrawalRequestForm()
    
    context = {
        'form': form,
        'earnings': earnings,
    }
    return render(request, 'payments/withdrawal_request.html', context)

@login_required
def payment_history(request):
    """User payment history"""
    payments = Payment.objects.filter(user=request.user).order_by('-created_at')
    
    context = {
        'payments': payments,
    }
    return render(request, 'payments/payment_history.html', context)