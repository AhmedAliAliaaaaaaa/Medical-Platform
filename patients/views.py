from django.shortcuts import render, redirect, get_object_or_404
from django.views.generic import TemplateView, CreateView, DetailView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.urls import reverse_lazy
from django.utils import timezone
from django.utils.translation import gettext as _
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
import json
from datetime import timedelta
from .models import Patient, MedicalCase, CaseAttachment, DoctorResponse, DoctorRating, PatientNotification
from doctors.models import Doctor
from payments.models import Payment, PaymentMethod
from .forms import MedicalCaseForm, CaseAttachmentForm, DoctorRatingForm
from core.translation_service import translation_service

class PatientRequiredMixin(LoginRequiredMixin):
    def dispatch(self, request, *args, **kwargs):
        if not request.user.is_authenticated or request.user.user_type != 'patient':
            messages.error(request, _('يجب أن تكون مريضاً مسجلاً للوصول لهذه الصفحة.'))
            return redirect('accounts:login')
        return super().dispatch(request, *args, **kwargs)

class PatientDashboardView(PatientRequiredMixin, TemplateView):
    template_name = 'patients/dashboard.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        patient = get_object_or_404(Patient, user=self.request.user)
        
        context['patient'] = patient
        # آخر 5 حالات
        recent_cases_qs = MedicalCase.objects.filter(patient=patient).order_by('-created_at')
        context['recent_cases'] = recent_cases_qs[:5]
        # إحصائيات سريعة
        context['pending_cases'] = recent_cases_qs.filter(status='pending').count()
        context['in_progress_cases'] = recent_cases_qs.filter(status='in_progress').count()
        context['completed_cases'] = recent_cases_qs.filter(status='completed').count()
        context['total_cases'] = recent_cases_qs.count()
        
        # الإشعارات
        notifications_qs = PatientNotification.objects.filter(patient=patient).order_by('-created_at')
        context['unread_notifications'] = notifications_qs.filter(is_read=False).count()
        context['recent_notifications'] = notifications_qs[:5]
        # جميع الحالات للمقطع داخل لوحة التحكم
        context['all_cases'] = recent_cases_qs[:20]  # عرض أول 20 حالة مع رابط للمزيد
        
        return context

class NewCaseView(PatientRequiredMixin, CreateView):
    model = MedicalCase
    form_class = MedicalCaseForm
    template_name = 'patients/new_case.html'
    
    def form_valid(self, form):
        patient = get_object_or_404(Patient, user=self.request.user)
        form.instance.patient = patient
        
        # Set case status as draft initially
        form.instance.status = 'draft'
        
        # Set expected response time based on priority
        if form.instance.priority == 'urgent':
            form.instance.expected_response_time = timezone.now() + timedelta(hours=24)
        else:
            form.instance.expected_response_time = timezone.now() + timedelta(hours=48)
        
        response = super().form_valid(form)
        
        # Handle file attachments
        files = self.request.FILES.getlist('attachments')
        for file in files:
            CaseAttachment.objects.create(
                case=self.object,
                file=file,
                file_type=self.get_file_type(file.name)
            )
        
        messages.success(self.request, _('تم حفظ حالتك كمسودة. سيتم توجيهك لاختيار الطبيب.'))
        return response
    
    def get_file_type(self, filename):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            return 'image'
        elif filename.lower().endswith('.pdf'):
            return 'pdf'
        else:
            return 'other'
    
    def get_success_url(self):
        return reverse_lazy('patients:select_doctor', kwargs={'case_id': self.object.id})

class SelectDoctorView(PatientRequiredMixin, TemplateView):
    template_name = 'patients/select_doctor.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        case_id = kwargs['case_id']
        case = get_object_or_404(MedicalCase, id=case_id, patient__user=self.request.user)
        
        doctors = Doctor.objects.filter(
            status='approved',
            is_available=True
        ).order_by('-rating')
        
        # حساب إحصائيات الأسعار
        if doctors.exists():
            consultation_fees = [d.consultation_fee for d in doctors if d.consultation_fee > 0]
            if consultation_fees:
                context['min_consultation_fee'] = min(consultation_fees)
                context['max_consultation_fee'] = max(consultation_fees)
                context['avg_consultation_fee'] = round(sum(consultation_fees) / len(consultation_fees), 2)
            else:
                context['min_consultation_fee'] = 0
                context['max_consultation_fee'] = 0
                context['avg_consultation_fee'] = 0
            
            # العملة الأكثر استخداماً
            currencies = [d.currency for d in doctors]
            context['currency'] = max(set(currencies), key=currencies.count) if currencies else 'SAR'
        else:
            context['min_consultation_fee'] = 0
            context['max_consultation_fee'] = 0
            context['avg_consultation_fee'] = 0
            context['currency'] = 'SAR'
        
        context['case'] = case
        context['doctors'] = doctors
        
        return context

class ConfirmCaseView(PatientRequiredMixin, TemplateView):
    template_name = 'patients/confirm_case.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        case_id = kwargs['case_id']
        doctor_id = kwargs['doctor_id']
        
        case = get_object_or_404(MedicalCase, id=case_id, patient__user=self.request.user)
        doctor = get_object_or_404(Doctor, id=doctor_id, status='approved')
        
        context['case'] = case
        context['doctor'] = doctor
        
        return context
    
    def post(self, request, *args, **kwargs):
        case_id = kwargs['case_id']
        doctor_id = kwargs['doctor_id']
        
        case = get_object_or_404(MedicalCase, id=case_id, patient__user=request.user)
        doctor = get_object_or_404(Doctor, id=doctor_id, status='approved')
        
        # ترجمة الحالة للطبيب حسب لغته المفضلة
        try:
            case_data = {
                'title': case.title,
                'description': case.description
            }
            
            # ترجمة للغة الطبيب المفضلة
            translated_case = translation_service.translate_case_for_doctor(
                case_data, 
                doctor.preferred_language
            )
            
            # حفظ الترجمة
            case.title_translated = translated_case.get('title_translated', case.title)
            case.description_translated = translated_case.get('description_translated', case.description)
            case.translation_confidence = translated_case.get('title_confidence', 0.0)
            
        except Exception as e:
            # في حالة فشل الترجمة، استمر بدون ترجمة
            pass
        
        case.doctor = doctor
        case.status = 'in_progress'
        case.save()
        
        messages.success(request, _('تم اختيار الطبيب بنجاح. سيتم توجيهك لصفحة الدفع.'))
        # Redirect to payment page
        consultation_type = request.POST.get('consultation_type', 'consultation')
        return redirect('patients:payment', case_id=case_id, doctor_id=doctor_id) + f'?type={consultation_type}'

class CaseDetailView(PatientRequiredMixin, DetailView):
    model = MedicalCase
    template_name = 'patients/case_detail.html'
    context_object_name = 'case'
    pk_url_kwarg = 'case_id'
    
    def get_queryset(self):
        return MedicalCase.objects.filter(patient__user=self.request.user)

class RateDoctorView(PatientRequiredMixin, CreateView):
    model = DoctorRating
    form_class = DoctorRatingForm
    template_name = 'patients/rate_doctor.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        case_id = self.kwargs['case_id']
        case = get_object_or_404(MedicalCase, id=case_id, patient__user=self.request.user)
        context['case'] = case
        return context
    
    def form_valid(self, form):
        case_id = self.kwargs['case_id']
        case = get_object_or_404(MedicalCase, id=case_id, patient__user=self.request.user)
        
        form.instance.patient = case.patient
        form.instance.doctor = case.doctor
        form.instance.case = case
        
        response = super().form_valid(form)
        
        # Update doctor's rating
        doctor = case.doctor
        ratings = DoctorRating.objects.filter(doctor=doctor)
        avg_rating = sum([r.rating for r in ratings]) / len(ratings)
        doctor.rating = round(avg_rating, 2)
        doctor.total_reviews = len(ratings)
        doctor.save()
        
        messages.success(self.request, _('شكراً لك على تقييم الطبيب!'))
        return response
    
    def get_success_url(self):
        return reverse_lazy('patients:dashboard')

class MyResponsesView(PatientRequiredMixin, TemplateView):
    template_name = 'patients/my_responses.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        patient = get_object_or_404(Patient, user=self.request.user)
        
        # الحصول على جميع الحالات المكتملة مع ردود الأطباء
        completed_cases = MedicalCase.objects.filter(
            patient=patient,
            status='completed'
        ).prefetch_related('responses__doctor__user').order_by('-created_at')
        
        context['completed_cases'] = completed_cases
        context['patient'] = patient
        
        return context


class AllCasesView(PatientRequiredMixin, TemplateView):
    template_name = 'patients/all_cases.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        patient = get_object_or_404(Patient, user=self.request.user)

        cases = MedicalCase.objects.filter(patient=patient).order_by('-created_at')
        context['cases'] = cases
        context['patient'] = patient
        return context


class NotificationsView(PatientRequiredMixin, TemplateView):
    template_name = 'patients/notifications.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        patient = get_object_or_404(Patient, user=self.request.user)
        
        # جلب جميع الإشعارات
        notifications = PatientNotification.objects.filter(
            patient=patient
        ).order_by('-created_at')
        
        context['notifications'] = notifications
        context['unread_count'] = notifications.filter(is_read=False).count()
        context['patient'] = patient
        
        return context
    
    def post(self, request, *args, **kwargs):
        from django.http import JsonResponse
        
        # تحديد الإشعار كمقروء
        notification_id = request.POST.get('notification_id')
        if notification_id:
            try:
                patient = get_object_or_404(Patient, user=request.user)
                notification = PatientNotification.objects.get(
                    id=notification_id, 
                    patient=patient
                )
                notification.is_read = True
                notification.save()
                return JsonResponse({'success': True})
            except PatientNotification.DoesNotExist:
                return JsonResponse({'success': False})
        
        # تحديد جميع الإشعارات كمقروءة
        if request.POST.get('mark_all_read'):
            patient = get_object_or_404(Patient, user=request.user)
            PatientNotification.objects.filter(
                patient=patient, 
                is_read=False
            ).update(is_read=True)
            messages.success(request, _('تم تحديد جميع الإشعارات كمقروءة'))
        
        return redirect('patients:notifications')


class PaymentView(PatientRequiredMixin, TemplateView):
    """صفحة الدفع للاستشارة الطبية"""
    template_name = 'patients/payment.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        case_id = kwargs['case_id']
        doctor_id = kwargs['doctor_id']
        
        case = get_object_or_404(MedicalCase, id=case_id, patient__user=self.request.user)
        doctor = get_object_or_404(Doctor, id=doctor_id, status='approved')
        
        # تحديد نوع الاستشارة والسعر
        consultation_type = self.request.GET.get('type', 'consultation')
        if consultation_type == 'emergency':
            amount = doctor.emergency_fee
            service_name = 'استشارة طوارئ'
        elif consultation_type == 'follow_up':
            amount = doctor.follow_up_fee
            service_name = 'متابعة'
        else:
            amount = doctor.consultation_fee
            service_name = 'استشارة طبية'
        
        context.update({
            'case': case,
            'doctor': doctor,
            'amount': amount,
            'currency': doctor.currency,
            'service_name': service_name,
            'consultation_type': consultation_type,
            'payment_methods': PaymentMethod.objects.filter(
                user=self.request.user, 
                is_active=True
            )
        })
        
        return context
    
    def post(self, request, *args, **kwargs):
        """معالجة الدفع"""
        case_id = kwargs['case_id']
        doctor_id = kwargs['doctor_id']
        
        case = get_object_or_404(MedicalCase, id=case_id, patient__user=request.user)
        doctor = get_object_or_404(Doctor, id=doctor_id, status='approved')
        
        payment_method_id = request.POST.get('payment_method')
        consultation_type = request.POST.get('consultation_type', 'consultation')
        
        # تحديد المبلغ
        if consultation_type == 'emergency':
            amount = doctor.emergency_fee
        elif consultation_type == 'follow_up':
            amount = doctor.follow_up_fee
        else:
            amount = doctor.consultation_fee
        
        try:
            # إنشاء عملية دفع
            payment = Payment.objects.create(
                user=request.user,
                case=case,
                doctor=doctor,
                amount=amount,
                currency=doctor.currency,
                payment_purpose=consultation_type,
                status='pending'
            )
            
            if payment_method_id:
                payment_method = get_object_or_404(
                    PaymentMethod, 
                    id=payment_method_id, 
                    user=request.user
                )
                payment.payment_method = payment_method
                payment.save()
            
            # محاكاة معالجة الدفع (في التطبيق الحقيقي، ستتم معالجة الدفع عبر بوابة الدفع)
            payment.status = 'completed'
            payment.paid_at = timezone.now()
            payment.save()
            
            # تحديث حالة الحالة الطبية
            case.doctor = doctor
            case.status = 'in_progress'
            case.save()
            
            # ترجمة الحالة للطبيب
            self._translate_case_for_doctor(case, doctor)
            
            messages.success(request, _('تم الدفع بنجاح! تم إرسال حالتك للطبيب.'))
            return redirect('patients:case_detail', case_id=case.id)
            
        except Exception as e:
            messages.error(request, f'حدث خطأ في عملية الدفع: {str(e)}')
            return redirect('patients:payment', case_id=case_id, doctor_id=doctor_id)
    
    def _translate_case_for_doctor(self, case, doctor):
        """ترجمة الحالة للطبيب"""
        try:
            case_data = {
                'title': case.title,
                'description': case.description
            }
            
            translated_case = translation_service.translate_case_for_doctor(
                case_data, 
                doctor.preferred_language
            )
            
            case.title_translated = translated_case.get('title_translated', case.title)
            case.description_translated = translated_case.get('description_translated', case.description)
            case.translation_confidence = translated_case.get('title_confidence', 0.0)
            case.save()
            
        except Exception as e:
            # تسجيل الخطأ ولكن لا تتوقف
            pass


@method_decorator(csrf_exempt, name='dispatch')
class InstantTranslationView(TemplateView):
    """API للترجمة الفورية"""
    
    def post(self, request, *args, **kwargs):
        try:
            data = json.loads(request.body)
            text = data.get('text', '')
            target_language = data.get('target_language', 'en')
            source_language = data.get('source_language', 'auto')
            
            if not text:
                return JsonResponse({
                    'success': False,
                    'error': 'النص مطلوب'
                })
            
            # تنفيذ الترجمة
            translation_result = translation_service.translate_text(
                text, 
                target_lang=target_language,
                source_lang=source_language,
                use_medical_dict=True
            )
            
            return JsonResponse({
                'success': True,
                'original_text': translation_result['original_text'],
                'translated_text': translation_result['translated_text'],
                'source_language': translation_result['source_lang'],
                'target_language': translation_result['target_lang'],
                'confidence': translation_result.get('confidence', 0.0),
                'medical_terms_found': translation_result.get('medical_terms_found', 0)
            })
            
        except Exception as e:
            return JsonResponse({
                'success': False,
                'error': str(e)
            })


class TestTranslationView(TemplateView):
    """صفحة اختبار الترجمة"""
    
    def get(self, request, *args, **kwargs):
        # قراءة ملف HTML للاختبار
        import os
        from django.http import HttpResponse
        from django.conf import settings
        
        test_file_path = os.path.join(settings.BASE_DIR, 'test_js.html')
        try:
            with open(test_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            return HttpResponse(content, content_type='text/html')
        except FileNotFoundError:
            return HttpResponse('<h1>ملف الاختبار غير موجود</h1>', content_type='text/html')


class MedicalSuggestionsView(PatientRequiredMixin, TemplateView):
    """API للحصول على اقتراحات المصطلحات الطبية"""
    
    def get(self, request, *args, **kwargs):
        query = request.GET.get('q', '')
        
        if not query or len(query) < 2:
            return JsonResponse({
                'suggestions': []
            })
        
        try:
            suggestions = translation_service.get_medical_suggestions(query, max_suggestions=10)
            return JsonResponse({
                'suggestions': suggestions
            })
            
        except Exception as e:
            return JsonResponse({
                'suggestions': [],
                'error': str(e)
            })
