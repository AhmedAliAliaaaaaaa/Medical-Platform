from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.contrib.auth.hashers import make_password
from django.contrib import messages
from django.core.paginator import Paginator
from django.db.models import Q, Count, Avg
from django.utils.translation import gettext as _
import json
import secrets
import string

from accounts.models import CustomUser
from doctors.models import Doctor
from patients.models import MedicalCase, DoctorResponse


@staff_member_required
@login_required
def manage_doctors(request):
    """عرض وإدارة جميع الأطباء"""
    
    # Get filter parameters
    status_filter = request.GET.get('status', '')
    specialization_filter = request.GET.get('specialization', '')
    availability_filter = request.GET.get('availability', '')
    search_query = request.GET.get('search', '')
    
    # Base queryset
    doctors = Doctor.objects.select_related('user').all()
    
    # Apply filters
    if status_filter:
        if status_filter == 'pending':
            doctors = doctors.filter(status='pending')
        elif status_filter == 'approved':
            doctors = doctors.filter(status='approved')
        elif status_filter == 'rejected':
            doctors = doctors.filter(status='rejected')
    
    if specialization_filter:
        doctors = doctors.filter(specialization=specialization_filter)
    
    if availability_filter:
        if availability_filter == 'available':
            doctors = doctors.filter(is_available=True)
        elif availability_filter == 'unavailable':
            doctors = doctors.filter(is_available=False)
    
    if search_query:
        doctors = doctors.filter(
            Q(user__first_name__icontains=search_query) |
            Q(user__last_name__icontains=search_query) |
            Q(user__email__icontains=search_query) |
            Q(user__username__icontains=search_query) |
            Q(specialization__icontains=search_query)
        )
    
    # Separate doctors by status
    pending_doctors = doctors.filter(status='pending')
    approved_doctors = doctors.filter(status='approved')
    rejected_doctors = doctors.filter(status='rejected')
    
    # Statistics
    total_doctors = doctors.count()
    pending_count = pending_doctors.count()
    approved_count = approved_doctors.count()
    rejected_count = rejected_doctors.count()
    available_count = doctors.filter(is_available=True).count()
    
    context = {
        'pending_doctors': pending_doctors,
        'approved_doctors': approved_doctors,
        'rejected_doctors': rejected_doctors,
        'total_doctors': total_doctors,
        'pending_count': pending_count,
        'approved_count': approved_count,
        'rejected_count': rejected_count,
        'available_count': available_count,
        'status_filter': status_filter,
        'specialization_filter': specialization_filter,
        'availability_filter': availability_filter,
        'search_query': search_query,
    }
    
    return render(request, 'admin_panel/manage_doctors.html', context)


@staff_member_required
@login_required
@require_http_methods(["GET"])
def get_doctor_password(request, doctor_id):
    """جلب كلمة مرور الطبيب (للعرض فقط)"""
    try:
        doctor = get_object_or_404(Doctor, id=doctor_id)
        
        # For security, we'll return a placeholder or generate a temporary view
        # In a real application, you might want to log this access
        
        # Since Django stores hashed passwords, we can't retrieve the original
        # Instead, we'll return a message indicating this
        return JsonResponse({
            'success': True,
            'password': 'كلمة المرور مشفرة - لا يمكن عرضها',
            'message': _('كلمة المرور مشفرة ولا يمكن عرضها. يمكنك إعادة تعيين كلمة مرور جديدة.')
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        })


@staff_member_required
@login_required
@require_http_methods(["POST"])
def reset_doctor_password(request, doctor_id):
    """إعادة تعيين كلمة مرور الطبيب"""
    try:
        doctor = get_object_or_404(Doctor, id=doctor_id)
        
        data = json.loads(request.body)
        new_password = data.get('password', '').strip()
        
        if not new_password or len(new_password) < 6:
            return JsonResponse({
                'success': False,
                'error': _('كلمة المرور يجب أن تكون 6 أحرف على الأقل')
            })
        
        # Update password
        doctor.user.password = make_password(new_password)
        doctor.user.save()
        
        # Log this action (optional)
        messages.success(request, _(f'تم تغيير كلمة مرور الطبيب {doctor.user.get_full_name()} بنجاح'))
        
        return JsonResponse({
            'success': True,
            'message': _('تم تغيير كلمة المرور بنجاح')
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        })


@staff_member_required
@login_required
@require_http_methods(["POST"])
def toggle_doctor_availability(request, doctor_id):
    """تبديل حالة إتاحة الطبيب"""
    try:
        doctor = get_object_or_404(Doctor, id=doctor_id)
        
        data = json.loads(request.body)
        is_available = data.get('is_available', False)
        
        # Update availability
        doctor.is_available = is_available
        doctor.save()
        
        status_text = _('متاح') if is_available else _('غير متاح')
        
        return JsonResponse({
            'success': True,
            'is_available': is_available,
            'status_text': status_text,
            'message': _(f'تم تحديث حالة الطبيب {doctor.user.get_full_name()} إلى {status_text}')
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        })


@staff_member_required
@login_required
def manage_doctor_responses(request):
    """إدارة ردود الأطباء"""
    
    # Get filter parameters
    status_filter = request.GET.get('status', '')
    response_type_filter = request.GET.get('response_type', '')
    specialization_filter = request.GET.get('specialization', '')
    search_query = request.GET.get('search', '')
    
    # Base queryset
    responses = DoctorResponse.objects.select_related(
        'doctor__user', 'medical_case__patient__user'
    ).all().order_by('-created_at')
    
    # Apply filters
    if status_filter:
        responses = responses.filter(status=status_filter)
    
    if response_type_filter:
        responses = responses.filter(response_type=response_type_filter)
    
    if specialization_filter:
        responses = responses.filter(doctor__specialization=specialization_filter)
    
    if search_query:
        responses = responses.filter(
            Q(doctor__user__first_name__icontains=search_query) |
            Q(doctor__user__last_name__icontains=search_query) |
            Q(medical_case__title__icontains=search_query) |
            Q(content__icontains=search_query)
        )
    
    # Pagination
    paginator = Paginator(responses, 20)
    page_number = request.GET.get('page')
    doctor_responses = paginator.get_page(page_number)
    
    # Statistics
    total_responses = responses.count()
    approved_responses = responses.filter(status='approved').count()
    pending_responses = responses.filter(status='pending').count()
    rejected_responses = responses.filter(status='rejected').count()
    
    context = {
        'doctor_responses': doctor_responses,
        'total_responses': total_responses,
        'approved_responses': approved_responses,
        'pending_responses': pending_responses,
        'rejected_responses': rejected_responses,
        'status_filter': status_filter,
        'response_type_filter': response_type_filter,
        'specialization_filter': specialization_filter,
        'search_query': search_query,
    }
    
    return render(request, 'admin_panel/manage_doctor_responses.html', context)


@staff_member_required
@login_required
@require_http_methods(["POST"])
def approve_doctor_response(request, response_id):
    """اعتماد رد الطبيب"""
    try:
        response = get_object_or_404(DoctorResponse, id=response_id)
        response.status = 'approved'
        response.save()
        
        return JsonResponse({
            'success': True,
            'message': _('تم اعتماد الرد بنجاح')
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        })


@staff_member_required
@login_required
@require_http_methods(["POST"])
def reject_doctor_response(request, response_id):
    """رفض رد الطبيب"""
    try:
        response = get_object_or_404(DoctorResponse, id=response_id)
        
        data = json.loads(request.body)
        rejection_reason = data.get('reason', '')
        
        response.status = 'rejected'
        response.rejection_reason = rejection_reason
        response.save()
        
        return JsonResponse({
            'success': True,
            'message': _('تم رفض الرد بنجاح')
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        })


@staff_member_required
@login_required
@require_http_methods(["DELETE"])
def delete_doctor_response(request, response_id):
    """حذف رد الطبيب"""
    try:
        response = get_object_or_404(DoctorResponse, id=response_id)
        doctor_name = response.doctor.user.get_full_name()
        response.delete()
        
        return JsonResponse({
            'success': True,
            'message': _(f'تم حذف رد الطبيب {doctor_name} بنجاح')
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        })


@staff_member_required
@login_required
def generate_random_password(length=12):
    """توليد كلمة مرور عشوائية قوية"""
    characters = string.ascii_letters + string.digits + "!@#$%^&*"
    password = ''.join(secrets.choice(characters) for _ in range(length))
    return password


@staff_member_required
@login_required
@require_http_methods(["POST"])
def bulk_doctor_actions(request):
    """إجراءات جماعية على الأطباء"""
    try:
        data = json.loads(request.body)
        action = data.get('action')
        doctor_ids = data.get('doctor_ids', [])
        
        if not doctor_ids:
            return JsonResponse({
                'success': False,
                'error': _('لم يتم تحديد أي طبيب')
            })
        
        doctors = Doctor.objects.filter(id__in=doctor_ids)
        
        if action == 'approve':
            doctors.update(status='approved')
            message = _(f'تم اعتماد {doctors.count()} طبيب بنجاح')
            
        elif action == 'reject':
            doctors.update(status='rejected')
            message = _(f'تم رفض {doctors.count()} طبيب بنجاح')
            
        elif action == 'make_available':
            doctors.update(is_available=True)
            message = _(f'تم جعل {doctors.count()} طبيب متاحين')
            
        elif action == 'make_unavailable':
            doctors.update(is_available=False)
            message = _(f'تم جعل {doctors.count()} طبيب غير متاحين')
            
        elif action == 'reset_passwords':
            for doctor in doctors:
                new_password = generate_random_password()
                doctor.user.password = make_password(new_password)
                doctor.user.save()
                # Here you might want to send the new password via email
            message = _(f'تم إعادة تعيين كلمات مرور {doctors.count()} طبيب')
            
        else:
            return JsonResponse({
                'success': False,
                'error': _('إجراء غير صحيح')
            })
        
        return JsonResponse({
            'success': True,
            'message': message
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        })