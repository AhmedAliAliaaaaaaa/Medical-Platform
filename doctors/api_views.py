from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db.models import Q, Count, Avg
from django.utils import timezone
from datetime import timedelta

from .models import Doctor, DoctorNotification
from patients.models import MedicalCase, DoctorResponse, Patient, PatientNotification, DoctorRating
from accounts.models import CustomUser
from payments.models import DoctorEarnings


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_dashboard(request):
    """لوحة تحكم الطبيب"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        
        # الإحصائيات
        total_cases = MedicalCase.objects.filter(doctor=doctor).count()
        pending_cases = MedicalCase.objects.filter(
            doctor=doctor,
            responses__isnull=True
        ).count()
        answered_cases = MedicalCase.objects.filter(
            doctor=doctor,
            responses__isnull=False
        ).distinct().count()
        unread_notifications = DoctorNotification.objects.filter(
            doctor=doctor,
            is_read=False
        ).count()
        
        # معلومات الطبيب
        doctor_info = {
            'specialization': doctor.get_specialization_display(),
            'experience_years': doctor.experience_years,
            'country': doctor.country,
            'status': doctor.get_status_display(),
        }
        
        # الحالات الجديدة (التي لم يتم الرد عليها فقط)
        new_cases = MedicalCase.objects.filter(
            doctor=doctor,
            status__in=['new', 'pending']
        ).order_by('-created_at')[:5]
        new_cases_data = []
        for case in new_cases:
            new_cases_data.append({
                'id': case.id,
                'title': case.title,
                'description': case.description,
                'symptoms': case.symptoms,
                'priority': case.priority,
                'patient_name': case.patient.user.get_full_name(),
                'created_at': case.created_at.strftime('%Y-%m-%d %H:%M'),
                'status': case.status,
                'has_response': False,
                'responses': [],
            })
        
        # الإشعارات الأخيرة
        recent_notifications = DoctorNotification.objects.filter(
            doctor=doctor
        ).order_by('-created_at')[:5]
        recent_notifications_data = []
        for notification in recent_notifications:
            recent_notifications_data.append({
                'id': notification.id,
                'title': notification.title,
                'message': notification.message,
                'type': notification.notification_type,
                'is_read': notification.is_read,
                'created_at': notification.created_at.strftime('%Y-%m-%d %H:%M'),
            })
        
        # جميع الحالات الجديدة
        new_cases_list = MedicalCase.objects.filter(
            doctor=doctor,
            responses__isnull=True
        ).order_by('-created_at')
        new_cases_list_data = []
        for case in new_cases_list:
            new_cases_list_data.append({
                'id': case.id,
                'title': case.title,
                'description': case.description,
                'symptoms': case.symptoms,
                'priority': case.priority,
                'patient_name': case.patient.user.get_full_name(),
                'created_at': case.created_at.strftime('%Y-%m-%d %H:%M'),
                'status': case.status,
                'has_response': False,
                'responses': [],
            })
        
        # الحالات قيد المراجعة
        pending_cases_list = MedicalCase.objects.filter(
            doctor=doctor,
            responses__status='pending'
        ).distinct().order_by('-created_at')
        pending_cases_list_data = []
        for case in pending_cases_list:
            pending_cases_list_data.append({
                'id': case.id,
                'title': case.title,
                'description': case.description,
                'symptoms': case.symptoms,
                'priority': case.priority,
                'patient_name': case.patient.user.get_full_name(),
                'created_at': case.created_at.strftime('%Y-%m-%d %H:%M'),
                'has_response': True,
            })
        
        # الحالات المجاب عليها
        answered_cases_list = MedicalCase.objects.filter(
            doctor=doctor,
            responses__status='approved'
        ).distinct().order_by('-created_at')
        answered_cases_list_data = []
        for case in answered_cases_list:
            answered_cases_list_data.append({
                'id': case.id,
                'title': case.title,
                'description': case.description,
                'symptoms': case.symptoms,
                'priority': case.priority,
                'patient_name': case.patient.user.get_full_name(),
                'created_at': case.created_at.strftime('%Y-%m-%d %H:%M'),
                'has_response': True,
            })
        
        # جميع الإشعارات
        all_notifications = DoctorNotification.objects.filter(
            doctor=doctor
        ).order_by('-created_at')
        all_notifications_data = []
        for notification in all_notifications:
            all_notifications_data.append({
                'id': notification.id,
                'title': notification.title,
                'message': notification.message,
                'type': notification.notification_type,
                'is_read': notification.is_read,
                'created_at': notification.created_at.strftime('%Y-%m-%d %H:%M'),
            })
        
        # ردود الطبيب
        my_responses = DoctorResponse.objects.filter(doctor=doctor).order_by('-created_at')
        my_responses_data = []
        for response in my_responses:
            my_responses_data.append({
                'id': response.id,
                'case_title': response.medical_case.title,
                'patient_name': response.medical_case.patient.user.get_full_name(),
                'content': response.content,
                'recommendations': response.recommendations,
                'status': response.status,
                'rejection_reason': response.rejection_reason or '',
                'created_at': response.created_at.strftime('%Y-%m-%d %H:%M'),
            })
        
        # التقييمات
        ratings = DoctorRating.objects.filter(doctor=doctor).order_by('-created_at')
        ratings_data = []
        average_rating = 0
        total_ratings = ratings.count()
        
        if total_ratings > 0:
            average_rating = ratings.aggregate(avg=Avg('rating'))['avg'] or 0
            
        for rating in ratings:
            ratings_data.append({
                'id': rating.id,
                'patient_name': rating.patient.user.get_full_name(),
                'rating': rating.rating,
                'comment': rating.comment,
                'created_at': rating.created_at.strftime('%Y-%m-%d %H:%M'),
            })
        
        # أرباح الطبيب إن وجدت
        total_earnings = 0
        try:
            earnings_obj = DoctorEarnings.objects.filter(doctor=doctor).first()
            if earnings_obj:
                total_earnings = float(earnings_obj.total_earnings)
        except Exception:
            total_earnings = 0

        return Response({
            'total_cases': total_cases,
            'pending_cases': pending_cases,
            'answered_cases': answered_cases,
            'unread_notifications': unread_notifications,
            'doctor_info': doctor_info,
            'new_cases': new_cases_data,
            'recent_notifications': recent_notifications_data,
            'new_cases_list': new_cases_list_data,
            'pending_cases_list': pending_cases_list_data,
            'answered_cases_list': answered_cases_list_data,
            'all_notifications': all_notifications_data,
            'my_responses': my_responses_data,
            'ratings': ratings_data,
            'average_rating': round(average_rating, 1),
            'total_ratings': total_ratings,
            'total_earnings': round(total_earnings, 2),
        })
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def respond_to_case(request, case_id):
    """الرد على حالة طبية"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        case = get_object_or_404(MedicalCase, id=case_id, doctor=doctor)
        
        content = request.data.get('content', '').strip()
        recommendations = request.data.get('recommendations', '').strip()
        
        if not content:
            return Response(
                {'error': 'محتوى الرد مطلوب'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # التحقق من عدم وجود رد سابق
        existing_response = DoctorResponse.objects.filter(
            medical_case=case,
            doctor=doctor
        ).first()
        
        if existing_response:
            return Response(
                {'error': 'تم الرد على هذه الحالة مسبقاً'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # إنشاء الرد
        response = DoctorResponse.objects.create(
            medical_case=case,
            doctor=doctor,
            content=content,
            recommendations=recommendations,
            status='pending'  # في انتظار موافقة الإدارة
        )
        
        # تحديث حالة القضية
        case.status = 'answered'
        case.save()

        # مسح الإشعارات المرتبطة بالحالة
        DoctorNotification.objects.filter(
            doctor=doctor,
            related_case=case
        ).update(is_read=True)
        
        # إرسال إشعار للمريض
        PatientNotification.objects.create(
            patient=case.patient,
            title='رد جديد من الطبيب',
            message=f'تم استلام رد من د. {doctor.user.get_full_name()} على حالتك',
            notification_type='doctor_response',
            related_case=case
        )
        
        # إرسال إشعار للإدارة
        from admin_panel.models import AdminNotification
        AdminNotification.objects.create(
            title='رد طبيب جديد',
            message=f'رد جديد من د. {doctor.user.get_full_name()} يحتاج للمراجعة',
            notification_type='doctor_response',
            related_doctor=doctor,
            related_case=case,
            related_response=response,
            created_by=request.user
        )
        
        return Response({
            'message': 'تم إرسال الرد بنجاح',
            'response_id': response.id
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_notification_read(request, notification_id):
    """تحديد الإشعار كمقروء"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        notification = get_object_or_404(
            DoctorNotification,
            id=notification_id,
            doctor=doctor
        )
        
        notification.is_read = True
        notification.save()
        
        return Response({'message': 'تم تحديث الإشعار'})
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def clear_case_notification(request, case_id):
    """مسح إشعار الحالة بعد الرد عليها"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        case = get_object_or_404(MedicalCase, id=case_id, doctor=doctor)

        # تحديث حالة الحالة إلى "answered"
        case.status = 'answered'
        case.save()

        # مسح الإشعارات المرتبطة بالحالة
        DoctorNotification.objects.filter(
            doctor=doctor,
            related_case=case
        ).update(is_read=True)

        return Response({'message': 'تم تحديث حالة الحالة ومسح الإشعارات'})

    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_case_status(request, case_id):
    """تحديث حالة الحالة"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        case = get_object_or_404(MedicalCase, id=case_id, doctor=doctor)

        status = request.data.get('status', '')
        if not status:
            return Response(
                {'error': 'حالة الحالة مطلوبة'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # تحديث حالة الحالة
        case.status = status
        case.save()

        return Response({'message': 'تم تحديث حالة الحالة'})

    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def case_details(request, case_id):
    """تفاصيل الحالة للطبيب"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        case = get_object_or_404(MedicalCase, id=case_id, doctor=doctor)
        
        case_data = {
            'id': case.id,
            'title': case.title,
            'description': case.description,
            'symptoms': case.symptoms,
            'status': case.status,
            'priority': case.priority,
            'patient_name': case.patient.user.get_full_name(),
            'created_at': case.created_at.strftime('%Y-%m-%d %H:%M'),
        }
        
        return Response(case_data)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_earnings_api(request):
    """أرباح الطبيب عبر API"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        earnings, _ = DoctorEarnings.objects.get_or_create(doctor=doctor)
        return Response({
            'total_earnings': float(earnings.total_earnings),
            'available_balance': float(earnings.available_balance),
            'pending_balance': float(earnings.pending_balance),
        })
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_notification(request):
    """إرسال إشعار للمريض أو الإدارة"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        
        recipient_type = request.data.get('recipient_type')  # 'patient' or 'admin'
        title = request.data.get('title', '').strip()
        message = request.data.get('message', '').strip()
        patient_id = request.data.get('patient_id')
        
        if not title or not message:
            return Response(
                {'error': 'العنوان والرسالة مطلوبان'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if recipient_type == 'patient':
            if not patient_id:
                return Response(
                    {'error': 'معرف المريض مطلوب'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            patient = get_object_or_404(Patient, id=patient_id)
            
            # التحقق من أن الطبيب له حالات مع هذا المريض
            has_cases = MedicalCase.objects.filter(
                doctor=doctor,
                patient=patient
            ).exists()
            
            if not has_cases:
                return Response(
                    {'error': 'لا يمكنك إرسال إشعار لهذا المريض'},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            PatientNotification.objects.create(
                patient=patient,
                title=title,
                message=message,
                notification_type='doctor_message',
                sender_doctor=doctor
            )
            
        elif recipient_type == 'admin':
            from admin_panel.models import AdminNotification
            AdminNotification.objects.create(
                title=f'رسالة من د. {doctor.user.get_full_name()}',
                message=message,
                notification_type='doctor_message',
                created_by=request.user
            )
        
        else:
            return Response(
                {'error': 'نوع المستلم غير صحيح'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        return Response({'message': 'تم إرسال الإشعار بنجاح'})
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_patients(request):
    """قائمة المرضى الذين لديهم حالات مع الطبيب"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        
        # الحصول على المرضى الذين لديهم حالات مع هذا الطبيب
        patients = Patient.objects.filter(
            medical_cases__doctor=doctor
        ).distinct()
        
        patients_data = []
        for patient in patients:
            cases_count = MedicalCase.objects.filter(
                doctor=doctor,
                patient=patient
            ).count()
            
            patients_data.append({
                'id': patient.id,
                'name': patient.user.get_full_name(),
                'email': patient.user.email,
                'cases_count': cases_count,
            })
        
        return Response({'patients': patients_data})
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
def available_doctors(request):
    """قائمة الأطباء المتاحين للمرضى"""
    try:
        doctors = Doctor.objects.filter(
            status='approved',
            is_available=True
        ).select_related('user')
        
        doctors_data = []
        for doctor in doctors:
            doctors_data.append({
                'id': doctor.id,
                'name': doctor.user.get_full_name(),
                'specialization': doctor.get_specialization_display(),
                'experience_years': doctor.experience_years,
                'country': doctor.country,
                'rating': float(doctor.rating),
                'total_reviews': doctor.total_reviews,
            })
        
        return Response({'doctors': doctors_data})
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_notifications(request):
    """جلب إشعارات الطبيب"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        
        # جلب الإشعارات مرتبة حسب التاريخ (الأحدث أولاً)
        notifications = DoctorNotification.objects.filter(
            doctor=doctor
        ).order_by('-created_at')
        
        notifications_data = []
        for notification in notifications:
            notifications_data.append({
                'id': notification.id,
                'title': notification.title,
                'message': notification.message,
                'notification_type': notification.notification_type,
                'is_read': notification.is_read,
                'created_at': notification.created_at.isoformat(),
                'case_id': notification.related_case.id if notification.related_case else None,
                'sender_patient_name': notification.sender_patient.user.get_full_name() if notification.sender_patient else None,
                'sender_admin_name': notification.sender_admin.get_full_name() if notification.sender_admin else None,
            })
        
        # حساب عدد الإشعارات غير المقروءة
        unread_count = notifications.filter(is_read=False).count()
        
        return Response({
            'notifications': notifications_data,
            'unread_count': unread_count
        })
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_all_notifications_read(request):
    """تحديد جميع إشعارات الطبيب كمقروءة"""
    try:
        doctor = get_object_or_404(Doctor, user=request.user)
        
        # تحديث جميع الإشعارات غير المقروءة
        updated_count = DoctorNotification.objects.filter(
            doctor=doctor,
            is_read=False
        ).update(is_read=True)
        
        return Response({
            'message': f'تم تحديد {updated_count} إشعار كمقروء',
            'updated_count': updated_count
        })
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )