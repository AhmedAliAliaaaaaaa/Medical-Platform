from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator
from django.views import View
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from django.core.paginator import Paginator
import json
from datetime import datetime, timedelta
from django.utils import timezone

from .models import Patient, MedicalCase, DoctorResponse, PatientNotification, CaseAttachment
from doctors.models import Doctor
from doctors.models import DoctorNotification
from accounts.models import CustomUser


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def patient_dashboard(request):
    """لوحة تحكم المريض"""
    try:
        patient = get_object_or_404(Patient, user=request.user)
        
        # إحصائيات الحالات
        total_cases = MedicalCase.objects.filter(patient=patient).count()
        pending_cases = MedicalCase.objects.filter(patient=patient, status='pending').count()
        answered_cases = MedicalCase.objects.filter(patient=patient, status='answered').count()
        
        # الإشعارات غير المقروءة
        unread_notifications = PatientNotification.objects.filter(
            patient=patient, 
            is_read=False
        ).count()
        
        # أحدث الحالات
        recent_cases = MedicalCase.objects.filter(patient=patient).order_by('-created_at')[:5]
        recent_cases_data = []
        for case in recent_cases:
            recent_cases_data.append({
                'id': case.id,
                'title': case.title,
                'status': case.status,
                'created_at': case.created_at.isoformat(),
                'doctor_name': case.doctor.user.get_full_name() if case.doctor else None,
            })
        
        # أحدث الإشعارات
        recent_notifications = PatientNotification.objects.filter(
            patient=patient
        ).order_by('-created_at')[:5]
        recent_notifications_data = []
        for notification in recent_notifications:
            recent_notifications_data.append({
                'id': notification.id,
                'title': notification.title,
                'message': notification.message,
                'is_read': notification.is_read,
                'created_at': notification.created_at.isoformat(),
            })
        
        # جميع الحالات للعرض التفصيلي
        all_cases = MedicalCase.objects.filter(patient=patient).order_by('-created_at')
        all_cases_data = []
        for case in all_cases:
            responses_count = DoctorResponse.objects.filter(medical_case=case).count()
            all_cases_data.append({
                'id': case.id,
                'title': case.title,
                'description': case.description,
                'symptoms': case.symptoms,
                'status': case.status,
                'priority': case.priority,
                'created_at': case.created_at.isoformat(),
                'doctor_name': case.doctor.user.get_full_name() if case.doctor else None,
                'doctor_specialization': case.doctor.specialization if case.doctor else None,
                'responses_count': responses_count,
            })
        
        # الحالات المعلقة
        pending_cases_list = MedicalCase.objects.filter(
            patient=patient, 
            status='pending'
        ).order_by('-created_at')
        pending_cases_data = []
        for case in pending_cases_list:
            pending_cases_data.append({
                'id': case.id,
                'title': case.title,
                'description': case.description,
                'symptoms': case.symptoms,
                'priority': case.priority,
                'created_at': case.created_at.isoformat(),
                'doctor_name': case.doctor.user.get_full_name() if case.doctor else None,
            })
        
        # الحالات المجابة
        answered_cases_list = MedicalCase.objects.filter(
            patient=patient, 
            status='completed'
        ).order_by('-created_at')
        answered_cases_data = []
        for case in answered_cases_list:
            latest_response = DoctorResponse.objects.filter(medical_case=case).order_by('-created_at').first()
            answered_cases_data.append({
                'id': case.id,
                'title': case.title,
                'description': case.description,
                'symptoms': case.symptoms,
                'priority': case.priority,
                'created_at': case.created_at.isoformat(),
                'doctor_name': case.doctor.user.get_full_name() if case.doctor else None,
                'latest_response': {
                    'diagnosis': latest_response.diagnosis if latest_response else None,
                    'treatment': latest_response.treatment_plan if latest_response else None,
                    'created_at': latest_response.created_at.isoformat() if latest_response else None,
                } if latest_response else None,
            })
        
        # جميع الإشعارات
        all_notifications = PatientNotification.objects.filter(
            patient=patient
        ).order_by('-created_at')
        all_notifications_data = []
        for notification in all_notifications:
            all_notifications_data.append({
                'id': notification.id,
                'title': notification.title,
                'message': notification.message,
                'is_read': notification.is_read,
                'created_at': notification.created_at.isoformat(),
            })
        
        return Response({
            'total_cases': total_cases,
            'pending_cases': pending_cases,
            'answered_cases': answered_cases,
            'unread_notifications': unread_notifications,
            'recent_cases': recent_cases_data,
            'recent_notifications': recent_notifications_data,
            'all_cases': all_cases_data,
            'pending_cases_list': pending_cases_data,
            'answered_cases_list': answered_cases_data,
            'all_notifications': all_notifications_data,
        })
        
    except Patient.DoesNotExist:
        return Response({
            'error': 'Patient profile not found'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def patient_cases(request):
    """إدارة حالات المريض"""
    try:
        patient = get_object_or_404(Patient, user=request.user)
        
        if request.method == 'GET':
            # الحصول على جميع الحالات
            cases = MedicalCase.objects.filter(patient=patient).order_by('-created_at')
            
            # تطبيق الفلترة
            status_filter = request.GET.get('status')
            if status_filter:
                cases = cases.filter(status=status_filter)
            
            # التصفح
            page = request.GET.get('page', 1)
            paginator = Paginator(cases, 10)
            cases_page = paginator.get_page(page)
            
            cases_data = []
            for case in cases_page:
                responses_count = DoctorResponse.objects.filter(medical_case=case).count()
                cases_data.append({
                    'id': case.id,
                    'title': case.title,
                    'description': case.description,
                    'symptoms': case.symptoms,
                    'status': case.status,
                    'priority': case.priority,
                    'created_at': case.created_at.isoformat(),
                    'doctor_name': case.doctor.user.get_full_name() if case.doctor else None,
                    'doctor_specialization': case.doctor.specialization if case.doctor else None,
                    'responses_count': responses_count,
                })
            
            return Response({
                'cases': cases_data,
                'total_pages': paginator.num_pages,
                'current_page': cases_page.number,
                'has_next': cases_page.has_next(),
                'has_previous': cases_page.has_previous(),
            })
        
        elif request.method == 'POST':
            # إنشاء حالة جديدة
            data = request.data
            
            # التحقق من البيانات المطلوبة
            required_fields = ['title', 'description', 'symptoms', 'doctor_id', 'priority']
            for field in required_fields:
                if field not in data:
                    return Response({
                        'error': f'Field {field} is required'
                    }, status=status.HTTP_400_BAD_REQUEST)
            
            # التحقق من وجود الطبيب
            try:
                doctor = Doctor.objects.get(id=data['doctor_id'], status='approved')
            except Doctor.DoesNotExist:
                return Response({
                    'error': 'Doctor not found or not approved'
                }, status=status.HTTP_404_NOT_FOUND)
            
            # إنشاء الحالة
            case = MedicalCase.objects.create(
                patient=patient,
                doctor=doctor,
                title=data['title'],
                description=data['description'],
                symptoms=data['symptoms'],
                priority=data.get('priority', 'medium'),
                status='pending'
            )
            
            # إنشاء إشعار للطبيب عند وصول حالة جديدة
            try:
                DoctorNotification.objects.create(
                    doctor=doctor,
                    title='حالة جديدة',
                    message=f'تم إرسال حالة جديدة من المريض {patient.user.get_full_name()}',
                    notification_type='new_case',
                    related_case=case,
                    sender_patient=patient
                )
            except Exception:
                # لا نُفشل إنشاء الحالة لو فشل الإشعار
                pass
            
            return Response({
                'message': 'Case created successfully',
                'case_id': case.id
            }, status=status.HTTP_201_CREATED)
            
    except Patient.DoesNotExist:
        return Response({
            'error': 'Patient profile not found'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def upload_case_attachments(request, case_id):
    """رفع مرفقات متعددة للحالة"""
    try:
        patient = get_object_or_404(Patient, user=request.user)
        case = get_object_or_404(MedicalCase, id=case_id, patient=patient)

        files = request.FILES.getlist('files')
        if not files:
            return Response({'error': 'No files provided'}, status=status.HTTP_400_BAD_REQUEST)

        created = 0
        for f in files:
            name = (f.name or '').lower()
            if name.endswith(('.png', '.jpg', '.jpeg', '.gif', '.webp')):
                ftype = 'image'
            elif name.endswith('.pdf'):
                ftype = 'pdf'
            else:
                ftype = 'other'
            CaseAttachment.objects.create(case=case, file=f, file_type=ftype)
            created += 1

        return Response({'message': 'uploaded', 'count': created}, status=status.HTTP_201_CREATED)
    except (Patient.DoesNotExist, MedicalCase.DoesNotExist):
        return Response({'error': 'Case not found'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def case_details(request, case_id):
    """تفاصيل الحالة الطبية"""
    try:
        patient = get_object_or_404(Patient, user=request.user)
        case = get_object_or_404(MedicalCase, id=case_id, patient=patient)
        
        # الحصول على جميع الردود
        responses = DoctorResponse.objects.filter(medical_case=case).order_by('created_at')
        responses_data = []
        for response in responses:
            # Build absolute URL helper
            def abs_url(field):
                try:
                    return request.build_absolute_uri(field.url) if field else None
                except Exception:
                    return None

            # Attachments for this response
            attachments = []
            try:
                for a in response.attachments.all():
                    url = abs_url(a.file)
                    attachments.append({
                        'id': a.id,
                        'file': url,
                        'file_url': url,  # compatibility with mobile app
                        'file_type': a.file_type,
                        'uploaded_at': a.uploaded_at.isoformat() if a.uploaded_at else None,
                    })
            except Exception:
                attachments = []

            responses_data.append({
                'id': response.id,
                'content': response.content,
                'recommendations': response.recommendations,
                'status': response.status,
                'diagnosis': response.diagnosis,
                'treatment_plan': response.treatment_plan,
                'notes': response.notes,
                'diagnosis_translated': response.diagnosis_translated,
                'treatment_plan_translated': response.treatment_plan_translated,
                'notes_translated': response.notes_translated,
                'response_language': response.response_language,
                'response_file': abs_url(response.response_file),
                'response_video': abs_url(response.response_video),
                'created_at': response.created_at.isoformat(),
                'updated_at': response.updated_at.isoformat(),
                'doctor': {
                    'id': response.doctor.id,
                    'full_name': response.doctor.user.get_full_name(),
                    'username': response.doctor.user.username,
                },
                'attachments': attachments,
            })
        
        case_data = {
            'id': case.id,
            'title': case.title,
            'description': case.description,
            'symptoms': case.symptoms,
            'status': case.status,
            'priority': case.priority,
            'created_at': case.created_at.isoformat(),
            'doctor_name': case.doctor.user.get_full_name() if case.doctor else None,
            'doctor_specialization': case.doctor.specialization if case.doctor else None,
            'responses': responses_data,
        }
        
        return Response(case_data)
        
    except (Patient.DoesNotExist, MedicalCase.DoesNotExist):
        return Response({
            'error': 'Case not found'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def patient_notifications(request):
    """إشعارات المريض"""
    try:
        patient = get_object_or_404(Patient, user=request.user)
        
        # الحصول على جميع الإشعارات
        notifications = PatientNotification.objects.filter(
            patient=patient
        ).order_by('-created_at')
        
        # تطبيق الفلترة
        is_read = request.GET.get('is_read')
        if is_read is not None:
            notifications = notifications.filter(is_read=is_read.lower() == 'true')
        
        # التصفح
        page = request.GET.get('page', 1)
        paginator = Paginator(notifications, 20)
        notifications_page = paginator.get_page(page)
        
        notifications_data = []
        for notification in notifications_page:
            notifications_data.append({
                'id': notification.id,
                'title': notification.title,
                'message': notification.message,
                'is_read': notification.is_read,
                'notification_type': notification.notification_type,
                'created_at': notification.created_at.isoformat(),
            })
        
        return Response({
            'notifications': notifications_data,
            'total_pages': paginator.num_pages,
            'current_page': notifications_page.number,
            'has_next': notifications_page.has_next(),
            'has_previous': notifications_page.has_previous(),
            'unread_count': PatientNotification.objects.filter(patient=patient, is_read=False).count(),
        })
        
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_notification_read(request, notification_id):
    """تحديد الإشعار كمقروء"""
    try:
        patient = get_object_or_404(Patient, user=request.user)
        notification = get_object_or_404(
            PatientNotification, 
            id=notification_id, 
            patient=patient
        )
        
        notification.is_read = True
        notification.save()
        
        return Response({
            'message': 'Notification marked as read'
        })
        
    except PatientNotification.DoesNotExist:
        return Response({
            'error': 'Notification not found'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_all_notifications_read(request):
    """تحديد جميع الإشعارات كمقروءة"""
    try:
        patient = get_object_or_404(Patient, user=request.user)
        PatientNotification.objects.filter(
            patient=patient, 
            is_read=False
        ).update(is_read=True)
        
        return Response({
            'message': 'All notifications marked as read'
        })
        
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def rate_doctor(request, case_id):
    """تقييم الطبيب"""
    try:
        patient = get_object_or_404(Patient, user=request.user)
        case = get_object_or_404(MedicalCase, id=case_id, patient=patient)
        
        data = request.data
        rating = data.get('rating')
        comment = data.get('comment', '')
        
        if not rating or not (1 <= int(rating) <= 5):
            return Response({
                'error': 'Rating must be between 1 and 5'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # إنشاء أو تحديث التقييم
        from doctors.models import DoctorRating
        rating_obj, created = DoctorRating.objects.get_or_create(
            doctor=case.doctor,
            patient=patient,
            case=case,
            defaults={
                'rating': rating,
                'comment': comment
            }
        )
        
        if not created:
            rating_obj.rating = rating
            rating_obj.comment = comment
            rating_obj.save()
        
        return Response({
            'message': 'Rating submitted successfully'
        })
        
    except (Patient.DoesNotExist, MedicalCase.DoesNotExist):
        return Response({
            'error': 'Case not found'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Legacy functions for backward compatibility
def create_case(request):
    """Legacy function - use patient_cases POST instead"""
    return patient_cases(request)


def patient_dashboard_legacy(request):
    """Legacy function - use patient_dashboard instead"""
    return patient_dashboard(request)