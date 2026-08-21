from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from django.db.models import Count, Avg
from django.utils import timezone

from doctors.models import Doctor, DoctorNotification
from patients.models import Patient, MedicalCase, DoctorResponse, PatientNotification, DoctorRating

User = get_user_model()


def _is_admin(user: User) -> bool:
    return getattr(user, 'user_type', None) == 'admin' or user.is_staff or user.is_superuser


def _get_doctor_by_any_id(doctor_id: int) -> Doctor:
    # Try doctor.id first
    doctor = Doctor.objects.filter(id=doctor_id).first()
    if doctor:
        return doctor
    # Fallback: doctor.user_id
    doctor = Doctor.objects.filter(user_id=doctor_id).first()
    if doctor:
        return doctor
    # Not found
    raise Doctor.DoesNotExist


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_doctor_profile_image(request, doctor_id: int):
    """رفع صورة الملف الشخصي للطبيب من قبل المشرف"""
    try:
        if not _is_admin(request.user):
            return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

        if 'profile_image' not in request.FILES:
            return Response({'detail': 'الحقل profile_image مطلوب'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            doctor = _get_doctor_by_any_id(doctor_id)
        except Doctor.DoesNotExist:
            return Response({'detail': 'الطبيب غير موجود'}, status=status.HTTP_404_NOT_FOUND)

        file_obj = request.FILES['profile_image']

        user = doctor.user
        user.profile_picture = file_obj
        user.save()

        file_url = request.build_absolute_uri(user.profile_picture.url)
        return Response({'success': True, 'profile_image': file_url}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_doctor_license_image(request, doctor_id: int):
    """رفع صورة الترخيص للطبيب من قبل المشرف"""
    try:
        if not _is_admin(request.user):
            return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

        if 'license_image' not in request.FILES:
            return Response({'detail': 'الحقل license_image مطلوب'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            doctor = _get_doctor_by_any_id(doctor_id)
        except Doctor.DoesNotExist:
            return Response({'detail': 'الطبيب غير موجود'}, status=status.HTTP_404_NOT_FOUND)

        file_obj = request.FILES['license_image']

        doctor.license_image = file_obj
        doctor.save()

        file_url = request.build_absolute_uri(doctor.license_image.url)
        return Response({'success': True, 'license_image': file_url}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ======================= ADMIN MANAGEMENT APIs =======================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_dashboard(request):
    """إحصائيات عامة للوحة تحكم المشرف"""
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    total_users = User.objects.count()
    total_patients = Patient.objects.count()
    total_doctors = Doctor.objects.count()
    approved_doctors = Doctor.objects.filter(status='approved').count()
    pending_doctors = Doctor.objects.filter(status='pending').count()
    total_cases = MedicalCase.objects.count()
    completed_cases = MedicalCase.objects.filter(status='completed').count()
    pending_cases = MedicalCase.objects.filter(status__in=['pending', 'in_progress']).count()

    # أحدث الحالات (آخر 10)
    recent_cases_qs = MedicalCase.objects.select_related('patient__user', 'doctor__user').order_by('-created_at')[:10]
    recent_cases = []
    for c in recent_cases_qs:
        recent_cases.append({
            'id': c.id,
            'title': c.title,
            'status': c.status,
            'patient': {
                'id': c.patient.id,
                'user': {
                    'id': c.patient.user.id,
                    'username': c.patient.user.username,
                    'get_full_name': c.patient.user.get_full_name(),
                }
            },
            'doctor': None if not c.doctor else {
                'id': c.doctor.id,
                'user': {
                    'id': c.doctor.user.id,
                    'username': c.doctor.user.username,
                    'get_full_name': c.doctor.user.get_full_name(),
                }
            },
            'created_at': c.created_at.strftime('%Y-%m-%d %H:%M'),
        })

    return Response({
        'total_users': total_users,
        'patients_count': total_patients,
        'total_patients': total_patients,
        'doctors_count': total_doctors,
        'approved_doctors': approved_doctors,
        'pending_doctors': pending_doctors,
        'total_cases': total_cases,
        'completed_cases': completed_cases,
        'pending_cases': pending_cases,
        'recent_cases': recent_cases,
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def pending_doctor_applications(request):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    qs = Doctor.objects.select_related('user').filter(status='pending').order_by('-created_at')
    doctors = []
    for d in qs:
        # Build absolute URLs for images if present
        profile_image_url = (
            request.build_absolute_uri(d.user.profile_picture.url)
            if getattr(d.user, 'profile_picture', None) and d.user.profile_picture
            else None
        )
        license_image_url = (
            request.build_absolute_uri(d.license_image.url)
            if getattr(d, 'license_image', None) and d.license_image
            else None
        )
        doctors.append({
            'id': d.id,
            'status': d.status,
            'specialization': d.specialization,
            'country': d.country,
            'experience_years': d.experience_years,
            'license_number': getattr(d, 'license_number', ''),
            'license_image': license_image_url,
            'created_at': d.created_at.strftime('%Y-%m-%d %H:%M'),
            'user': {
                'id': d.user.id,
                'username': d.user.username,
                'email': d.user.email,
                'first_name': d.user.first_name,
                'last_name': d.user.last_name,
                'get_full_name': d.user.get_full_name(),
                'phone': getattr(d.user, 'phone_number', '') or '',
                'profile_image': profile_image_url,
            }
        })
    return Response({'doctors': doctors})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def approve_doctor_application(request):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    doctor_id = request.data.get('application_id') or request.data.get('doctor_id')
    if not doctor_id:
        return Response({'detail': 'application_id مطلوب'}, status=status.HTTP_400_BAD_REQUEST)

    doctor = get_object_or_404(Doctor, id=doctor_id)
    doctor.status = 'approved'
    doctor.save()

    # تأكيد نوع المستخدم
    user = doctor.user
    if getattr(user, 'user_type', None) != 'doctor':
        user.user_type = 'doctor'
        user.save(update_fields=['user_type'])

    return Response({'success': True, 'message': 'تمت الموافقة على الطبيب', 'doctor_id': doctor.id})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reject_doctor_application(request):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    doctor_id = request.data.get('application_id') or request.data.get('doctor_id')
    reason = (request.data.get('reason') or '').strip()
    if not doctor_id:
        return Response({'detail': 'application_id مطلوب'}, status=status.HTTP_400_BAD_REQUEST)

    doctor = get_object_or_404(Doctor, id=doctor_id)
    doctor.status = 'rejected'
    doctor.save()

    # إشعار للطبيب اختياري
    try:
        DoctorNotification.objects.create(
            doctor=doctor,
            title='تم رفض الطلب',
            message=f'تم رفض طلبك. السبب: {reason or "غير محدد"}',
            notification_type='admin',
        )
    except Exception:
        pass

    return Response({'success': True, 'message': 'تم رفض الطبيب', 'doctor_id': doctor.id})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_doctors(request):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    qs = Doctor.objects.select_related('user').order_by('-created_at')
    data = []
    for d in qs:
        profile_image_url = (
            request.build_absolute_uri(d.user.profile_picture.url)
            if getattr(d.user, 'profile_picture', None) and d.user.profile_picture
            else None
        )
        license_image_url = (
            request.build_absolute_uri(d.license_image.url)
            if getattr(d, 'license_image', None) and d.license_image
            else None
        )
        data.append({
            'id': d.id,
            'status': d.status,
            'specialization': d.specialization,
            'country': d.country,
            'experience_years': d.experience_years,
            'license_number': getattr(d, 'license_number', ''),
            'license_image': license_image_url,
            'rating': float(d.rating),
            'cases_count': MedicalCase.objects.filter(doctor=d).count(),
            'created_at': d.created_at.strftime('%Y-%m-%d %H:%M'),
            'user_status': 'active' if d.user.is_active else 'blocked',
            'phone': getattr(d.user, 'phone_number', '') or '',
            'profile_image': profile_image_url,
            'user': {
                'id': d.user.id,
                'username': d.user.username,
                'email': d.user.email,
                'first_name': d.user.first_name,
                'last_name': d.user.last_name,
            }
        })
    return Response({'doctors': data})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_patients(request):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    qs = Patient.objects.select_related('user').order_by('-created_at')
    data = []
    for p in qs:
        data.append({
            'id': p.id,
            'cases_count': p.medical_cases.count(),
            'created_at': p.created_at.strftime('%Y-%m-%d %H:%M'),
            'status': 'active' if p.user.is_active else 'blocked',
            'user': {
                'id': p.user.id,
                'username': p.user.username,
                'email': p.user.email,
                'first_name': p.user.first_name,
                'last_name': p.user.last_name,
                'phone': getattr(p.user, 'phone_number', '') or '',
            }
        })
    return Response({'patients': data})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def system_statistics(request):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    total_users = User.objects.count()
    total_cases = MedicalCase.objects.count()
    completed_cases = MedicalCase.objects.filter(status='completed').count()
    active_doctors = Doctor.objects.filter(status='approved', is_available=True).count()

    # أعلى التخصصات حسب عدد الأطباء
    top_specs = (
        Doctor.objects.values('specialization')
        .annotate(count=Count('id'))
        .order_by('-count')[:5]
    )
    top_specializations = [
        {'specialization': s['specialization'], 'count': s['count']} for s in top_specs
    ]

    return Response({
        'total_users': total_users,
        'total_cases': total_cases,
        'completed_cases': completed_cases,
        'active_doctors': active_doctors,
        'growth': {'users': 0, 'cases': 0, 'revenue': 0},
        'top_specializations': top_specializations,
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_cases(request):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    qs = (
        MedicalCase.objects.select_related('patient__user', 'doctor__user')
        .prefetch_related('responses__doctor__user')
        .order_by('-created_at')
    )
    data = []
    for c in qs:
        responses = []
        for r in c.responses.all().order_by('-created_at'):
            responses.append({
                'id': r.id,
                'content': r.content,
                'recommendations': r.recommendations,
                'status': r.status,
                'created_at': r.created_at.strftime('%Y-%m-%d %H:%M'),
                'doctor': {
                    'id': r.doctor.id,
                    'user': {
                        'id': r.doctor.user.id,
                        'username': r.doctor.user.username,
                        'get_full_name': r.doctor.user.get_full_name(),
                    }
                }
            })
        data.append({
            'id': c.id,
            'title': c.title,
            'description': c.description,
            'status': c.status,
            'priority': c.priority,
            'created_at': c.created_at.strftime('%Y-%m-%d %H:%M'),
            'patient': {
                'id': c.patient.id,
                'user': {
                    'id': c.patient.user.id,
                    'username': c.patient.user.username,
                    'get_full_name': c.patient.user.get_full_name(),
                }
            },
            'doctor': None if not c.doctor else {
                'id': c.doctor.id,
                'user': {
                    'id': c.doctor.user.id,
                    'username': c.doctor.user.username,
                    'get_full_name': c.doctor.user.get_full_name(),
                }
            },
            'responses': responses,
        })
    return Response({'cases': data})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def case_details(request, case_id: int):
    """تفاصيل حالة طبية للمشرف"""
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    try:
        case = get_object_or_404(
            MedicalCase.objects.select_related('patient__user', 'doctor__user')
            .prefetch_related('responses__doctor__user', 'attachments'),
            id=case_id
        )
        
        # جمع الردود
        responses = []
        for r in case.responses.all().order_by('-created_at'):
            responses.append({
                'id': r.id,
                'content': r.content,
                'recommendations': r.recommendations,
                'diagnosis': r.diagnosis,
                'treatment_plan': r.treatment_plan,
                'notes': r.notes,
                'status': r.status,
                'rejection_reason': r.rejection_reason,
                'created_at': r.created_at.strftime('%Y-%m-%d %H:%M'),
                'updated_at': r.updated_at.strftime('%Y-%m-%d %H:%M'),
                'doctor': {
                    'id': r.doctor.id,
                    'user': {
                        'id': r.doctor.user.id,
                        'username': r.doctor.user.username,
                        'get_full_name': r.doctor.user.get_full_name(),
                        'first_name': r.doctor.user.first_name,
                        'last_name': r.doctor.user.last_name,
                    },
                    'specialization': r.doctor.specialization,
                }
            })
        
        # جمع المرفقات
        attachments = []
        for att in case.attachments.all():
            attachments.append({
                'id': att.id,
                'file': att.file.url if att.file else None,
                'file_type': att.file_type,
                'uploaded_at': att.uploaded_at.strftime('%Y-%m-%d %H:%M'),
            })
        
        case_data = {
            'id': case.id,
            'title': case.title,
            'description': case.description,
            'symptoms': case.symptoms,
            'status': case.status,
            'priority': case.priority,
            'created_at': case.created_at.strftime('%Y-%m-%d %H:%M'),
            'updated_at': case.updated_at.strftime('%Y-%m-%d %H:%M'),
            'expected_response_time': case.expected_response_time.strftime('%Y-%m-%d %H:%M') if case.expected_response_time else None,
            'patient': {
                'id': case.patient.id,
                'user': {
                    'id': case.patient.user.id,
                    'username': case.patient.user.username,
                    'get_full_name': case.patient.user.get_full_name(),
                    'first_name': case.patient.user.first_name,
                    'last_name': case.patient.user.last_name,
                    'email': case.patient.user.email,
                    'phone_number': case.patient.user.phone_number,
                },
                'date_of_birth': case.patient.date_of_birth.strftime('%Y-%m-%d') if case.patient.date_of_birth else None,
                'gender': case.patient.gender,
                'blood_type': case.patient.blood_type,
                'medical_history': case.patient.medical_history,
                'allergies': case.patient.allergies,
                'emergency_contact': case.patient.emergency_contact,
            },
            'doctor': None if not case.doctor else {
                'id': case.doctor.id,
                'user': {
                    'id': case.doctor.user.id,
                    'username': case.doctor.user.username,
                    'get_full_name': case.doctor.user.get_full_name(),
                    'first_name': case.doctor.user.first_name,
                    'last_name': case.doctor.user.last_name,
                    'email': case.doctor.user.email,
                    'phone_number': case.doctor.user.phone_number,
                },
                'specialization': case.doctor.specialization,
                'experience_years': case.doctor.experience_years,
                'license_number': case.doctor.license_number,
                'status': case.doctor.status,
            },
            'responses': responses,
            'attachments': attachments,
        }
        
        return Response({'case': case_data})
        
    except Exception as e:
        return Response(
            {'detail': f'خطأ في تحميل تفاصيل الحالة: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_doctor_status(request, doctor_id: int):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    status_value = (request.data.get('status') or '').strip()
    if status_value not in {'pending', 'approved', 'rejected'}:
        return Response({'detail': 'قيمة الحالة غير صحيحة'}, status=status.HTTP_400_BAD_REQUEST)

    doctor = get_object_or_404(Doctor, id=doctor_id)
    doctor.status = status_value
    doctor.save(update_fields=['status'])
    return Response({'success': True, 'doctor_id': doctor.id, 'status': doctor.status})


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_user_status(request, user_id: int):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    status_value = (request.data.get('status') or '').strip()
    if status_value not in {'active', 'blocked'}:
        return Response({'detail': 'قيمة الحالة غير صحيحة'}, status=status.HTTP_400_BAD_REQUEST)

    user = get_object_or_404(User, id=user_id)
    user.is_active = status_value == 'active'
    user.save(update_fields=['is_active'])
    return Response({'success': True, 'user_id': user.id, 'status': 'active' if user.is_active else 'blocked'})


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_doctor(request, doctor_id: int):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    doctor = get_object_or_404(Doctor, id=doctor_id)
    user = doctor.user
    doctor.delete()
    return Response({'success': True, 'doctor_deleted': doctor_id, 'user_id': user.id})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_details(request, doctor_id: int):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    try:
        doctor = _get_doctor_by_any_id(doctor_id)
    except Doctor.DoesNotExist:
        return Response({'detail': 'الطبيب غير موجود'}, status=status.HTTP_404_NOT_FOUND)
    user = doctor.user

    profile_image_url = (
        request.build_absolute_uri(user.profile_picture.url)
        if getattr(user, 'profile_picture', None) and user.profile_picture
        else None
    )
    license_image_url = (
        request.build_absolute_uri(doctor.license_image.url)
        if getattr(doctor, 'license_image', None) and doctor.license_image
        else None
    )

    data = {
        'id': doctor.id,
        'status': doctor.status,
        'specialization': doctor.specialization,
        'country': doctor.country,
        'experience_years': doctor.experience_years,
        'license_number': getattr(doctor, 'license_number', ''),
        'license_image': license_image_url,
        'rating': float(doctor.rating),
        'cases_count': MedicalCase.objects.filter(doctor=doctor).count(),
        'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone': getattr(user, 'phone_number', '') or '',
            'profile_image': profile_image_url,
        },
        'bio': getattr(doctor, 'bio', ''),
        'preferred_language': getattr(doctor, 'preferred_language', 'ar'),
        'consultation_fee': str(getattr(doctor, 'consultation_fee', '')),
        'emergency_fee': str(getattr(doctor, 'emergency_fee', '')),
        'follow_up_fee': str(getattr(doctor, 'follow_up_fee', '')),
        'currency': getattr(doctor, 'currency', 'SAR'),
        'accepts_insurance': getattr(doctor, 'accepts_insurance', False),
    }
    return Response(data)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_doctor(request, doctor_id: int):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    doctor = get_object_or_404(Doctor, id=doctor_id)
    user = doctor.user

    # Optional fields
    user.first_name = request.data.get('first_name', user.first_name)
    user.last_name = request.data.get('last_name', user.last_name)
    user.email = request.data.get('email', user.email)
    if hasattr(user, 'phone_number'):
        user.phone_number = request.data.get('phone', user.phone_number)
    user.save()

    doctor.specialization = request.data.get('specialization', doctor.specialization)
    doctor.country = request.data.get('country', doctor.country)
    exp = request.data.get('experience_years')
    if exp is not None:
        try:
            doctor.experience_years = int(exp)
        except Exception:
            pass
    doctor.save()

    return Response({'success': True, 'doctor_id': doctor.id})


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_patient(request, patient_id: int):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    patient = get_object_or_404(Patient, id=patient_id)
    user = patient.user

    user.first_name = request.data.get('first_name', user.first_name)
    user.last_name = request.data.get('last_name', user.last_name)
    user.email = request.data.get('email', user.email)
    if hasattr(user, 'phone_number'):
        user.phone_number = request.data.get('phone', user.phone_number)
    user.save()

    return Response({'success': True, 'patient_id': patient.id})


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_patient(request, patient_id: int):
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    patient = get_object_or_404(Patient, id=patient_id)
    user = patient.user
    patient.delete()
    return Response({'success': True, 'patient_deleted': patient_id, 'user_id': user.id})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_broadcast_notification(request):
    """إرسال إشعار جماعي للمستخدمين"""
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    title = (request.data.get('title') or '').strip()
    message = (request.data.get('message') or '').strip()
    user_type = (request.data.get('user_type') or '').strip()  # 'patient' | 'doctor' | ''

    if not title or not message:
        return Response({'detail': 'العنوان والرسالة مطلوبان'}, status=status.HTTP_400_BAD_REQUEST)

    created = 0
    if user_type in ('', 'patient'):
        for p in Patient.objects.all().select_related('user'):
            PatientNotification.objects.create(
                patient=p,
                title=title,
                message=message,
                notification_type='admin',
            )
            created += 1
    if user_type in ('', 'doctor'):
        for d in Doctor.objects.all().select_related('user'):
            DoctorNotification.objects.create(
                doctor=d,
                title=title,
                message=message,
                notification_type='admin',
            )
            created += 1

    return Response({'success': True, 'created': created})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_individual_notification(request):
    """إرسال إشعار فردي لمستخدم محدد"""
    if not _is_admin(request.user):
        return Response({'detail': 'غير مصرح'}, status=status.HTTP_403_FORBIDDEN)

    title = (request.data.get('title') or '').strip()
    message = (request.data.get('message') or '').strip()
    recipient_type = (request.data.get('recipient_type') or '').strip()  # 'patient' | 'doctor'
    recipient_id = request.data.get('recipient_id')

    if not title or not message:
        return Response({'detail': 'العنوان والرسالة مطلوبان'}, status=status.HTTP_400_BAD_REQUEST)

    if not recipient_type or recipient_type not in ['patient', 'doctor']:
        return Response({'detail': 'نوع المستلم غير صحيح'}, status=status.HTTP_400_BAD_REQUEST)

    if not recipient_id:
        return Response({'detail': 'معرف المستلم مطلوب'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        recipient_id = int(recipient_id)
    except (ValueError, TypeError):
        return Response({'detail': 'معرف المستلم غير صحيح'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        if recipient_type == 'patient':
            patient = get_object_or_404(Patient, id=recipient_id)
            PatientNotification.objects.create(
                patient=patient,
                title=title,
                message=message,
                notification_type='admin',
                sender_admin=request.user,
            )
            recipient_name = patient.user.get_full_name()
        else:  # doctor
            doctor = get_object_or_404(Doctor, id=recipient_id)
            DoctorNotification.objects.create(
                doctor=doctor,
                title=title,
                message=message,
                notification_type='admin',
                sender_admin=request.user,
            )
            recipient_name = doctor.user.get_full_name()

        return Response({
            'success': True,
            'message': f'تم إرسال الإشعار بنجاح إلى {recipient_name}',
            'recipient_name': recipient_name,
        })

    except Exception as e:
        return Response({
            'detail': f'حدث خطأ أثناء إرسال الإشعار: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)