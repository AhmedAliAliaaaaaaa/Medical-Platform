from django.shortcuts import render, redirect, get_object_or_404
from django.views.generic import TemplateView, CreateView, DetailView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.urls import reverse_lazy
from django.utils.translation import gettext as _
from .models import Doctor
from patients.models import MedicalCase, DoctorResponse
from .forms import DoctorResponseForm

class DoctorRequiredMixin(LoginRequiredMixin):
    def dispatch(self, request, *args, **kwargs):
        if not request.user.is_authenticated or request.user.user_type != 'doctor':
            messages.error(request, _('يجب أن تكون طبيباً مسجلاً للوصول لهذه الصفحة.'))
            return redirect('accounts:login')
        return super().dispatch(request, *args, **kwargs)

class PendingApprovalView(DoctorRequiredMixin, TemplateView):
    template_name = 'doctors/pending.html'
    
    def dispatch(self, request, *args, **kwargs):
        try:
            doctor = Doctor.objects.get(user=request.user)
            if doctor.status == 'approved':
                return redirect('doctors:dashboard')
            elif doctor.status == 'rejected':
                messages.error(request, _('تم رفض طلبك للانضمام كطبيب.'))
                return redirect('core:home')
        except Doctor.DoesNotExist:
            messages.error(request, _('لم يتم العثور على ملف الطبيب.'))
            return redirect('core:home')
        
        return super().dispatch(request, *args, **kwargs)

class DoctorDashboardView(TemplateView):
    template_name = 'doctors/dashboard.html'
    
    def dispatch(self, request, *args, **kwargs):
        # إذا لم يكن المستخدم مسجل دخول، حوله لصفحة تسجيل الدخول
        if not request.user.is_authenticated:
            return redirect('accounts:login')
        
        # إذا لم يكن طبيب، حوله للصفحة الرئيسية
        if request.user.user_type != 'doctor':
            messages.error(request, _('يجب أن تكون طبيباً مسجلاً للوصول لهذه الصفحة.'))
            return redirect('core:home')
        
        try:
            doctor = Doctor.objects.get(user=request.user)
            if doctor.status != 'approved':
                return redirect('doctors:pending')
        except Doctor.DoesNotExist:
            messages.error(request, _('لم يتم العثور على ملف الطبيب.'))
            return redirect('core:home')
        
        return super().dispatch(request, *args, **kwargs)
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        doctor = get_object_or_404(Doctor, user=self.request.user)
        
        context['doctor'] = doctor
        context['new_cases'] = MedicalCase.objects.filter(
            doctor=doctor,
            status__in=['pending', 'in_progress']
        ).order_by('-created_at')
        context['completed_cases'] = MedicalCase.objects.filter(
            doctor=doctor,
            status='completed'
        ).count()
        context['pending_cases'] = MedicalCase.objects.filter(
            doctor=doctor,
            status='pending'
        ).count()
        context['total_cases'] = MedicalCase.objects.filter(doctor=doctor).count()
        
        # إضافة التقييمات
        from patients.models import DoctorRating
        from .models import DoctorNotification
        ratings = DoctorRating.objects.filter(doctor=doctor).select_related('patient__user', 'case').order_by('-created_at')
        context['recent_ratings'] = ratings[:5]
        context['total_ratings'] = ratings.count()
        
        # إضافة الإشعارات
        notifications = DoctorNotification.objects.filter(doctor=doctor)
        context['unread_notifications'] = notifications.filter(is_read=False).count()
        
        # حساب متوسط التقييمات التفصيلية
        if ratings.exists():
            context['avg_diagnosis_accuracy'] = sum([r.diagnosis_accuracy for r in ratings]) / len(ratings)
            context['avg_treatment_clarity'] = sum([r.treatment_clarity for r in ratings]) / len(ratings)
            context['avg_response_speed'] = sum([r.response_speed for r in ratings]) / len(ratings)
            context['avg_professionalism'] = sum([r.professionalism for r in ratings]) / len(ratings)
            context['avg_communication'] = sum([r.communication for r in ratings]) / len(ratings)
            context['avg_overall_satisfaction'] = sum([r.overall_satisfaction for r in ratings]) / len(ratings)
        else:
            context['avg_diagnosis_accuracy'] = 0
            context['avg_treatment_clarity'] = 0
            context['avg_response_speed'] = 0
            context['avg_professionalism'] = 0
            context['avg_communication'] = 0
            context['avg_overall_satisfaction'] = 0
        
        return context

class CaseDetailView(DoctorRequiredMixin, DetailView):
    model = MedicalCase
    template_name = 'doctors/case_detail.html'
    context_object_name = 'case'
    pk_url_kwarg = 'case_id'
    
    def get_queryset(self):
        doctor = get_object_or_404(Doctor, user=self.request.user)
        return MedicalCase.objects.filter(doctor=doctor)

class RespondToCaseView(DoctorRequiredMixin, CreateView):
    model = DoctorResponse
    form_class = DoctorResponseForm
    template_name = 'doctors/respond_case.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        case_id = self.kwargs['case_id']
        doctor = get_object_or_404(Doctor, user=self.request.user)
        case = get_object_or_404(MedicalCase, id=case_id, doctor=doctor)
        context['case'] = case
        return context
    
    def form_valid(self, form):
        case_id = self.kwargs['case_id']
        doctor = get_object_or_404(Doctor, user=self.request.user)
        case = get_object_or_404(MedicalCase, id=case_id, doctor=doctor)
        
        form.instance.medical_case = case
        form.instance.doctor = doctor
        
        response = super().form_valid(form)
        
        # Update case status
        case.status = 'completed'
        case.save()
        
        messages.success(self.request, _('تم إرسال ردك بنجاح!'))
        return response
    
    def get_success_url(self):
        return reverse_lazy('doctors:dashboard')

class AllPatientCasesView(DoctorRequiredMixin, TemplateView):
    template_name = 'doctors/all_patient_cases.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        doctor = get_object_or_404(Doctor, user=self.request.user)
        context['doctor'] = doctor
        context['cases'] = MedicalCase.objects.filter(doctor=doctor).order_by('-created_at')
        return context


class MyResponsesView(DoctorRequiredMixin, TemplateView):
    template_name = 'doctors/my_responses.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        doctor = get_object_or_404(Doctor, user=self.request.user)
        
        context['responses'] = DoctorResponse.objects.filter(
            doctor=doctor
        ).order_by('-created_at')
        
        return context


class MyRatingsView(DoctorRequiredMixin, TemplateView):
    template_name = 'doctors/my_ratings.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        doctor = get_object_or_404(Doctor, user=self.request.user)
        
        from patients.models import DoctorRating
        ratings = DoctorRating.objects.filter(doctor=doctor).select_related('patient__user', 'case').order_by('-created_at')
        
        context['ratings'] = ratings
        context['total_ratings'] = ratings.count()
        context['doctor'] = doctor
        
        # حساب الإحصائيات التفصيلية
        if ratings.exists():
            context['avg_diagnosis_accuracy'] = sum([r.diagnosis_accuracy for r in ratings]) / len(ratings)
            context['avg_treatment_clarity'] = sum([r.treatment_clarity for r in ratings]) / len(ratings)
            context['avg_response_speed'] = sum([r.response_speed for r in ratings]) / len(ratings)
            context['avg_professionalism'] = sum([r.professionalism for r in ratings]) / len(ratings)
            context['avg_communication'] = sum([r.communication for r in ratings]) / len(ratings)
            context['avg_overall_satisfaction'] = sum([r.overall_satisfaction for r in ratings]) / len(ratings)
            context['overall_average'] = sum([r.rating for r in ratings]) / len(ratings)
            
            # حساب النسب المئوية للشرائط التقدمية (من 5 إلى 100%)
            context['diagnosis_accuracy_percent'] = (context['avg_diagnosis_accuracy'] / 5) * 100
            context['treatment_clarity_percent'] = (context['avg_treatment_clarity'] / 5) * 100
            context['response_speed_percent'] = (context['avg_response_speed'] / 5) * 100
            context['professionalism_percent'] = (context['avg_professionalism'] / 5) * 100
            context['communication_percent'] = (context['avg_communication'] / 5) * 100
            context['overall_satisfaction_percent'] = (context['avg_overall_satisfaction'] / 5) * 100
            
            # توزيع التقييمات
            context['rating_distribution'] = {
                5: ratings.filter(rating__gte=4.5).count(),
                4: ratings.filter(rating__gte=3.5, rating__lt=4.5).count(),
                3: ratings.filter(rating__gte=2.5, rating__lt=3.5).count(),
                2: ratings.filter(rating__gte=1.5, rating__lt=2.5).count(),
                1: ratings.filter(rating__lt=1.5).count(),
            }
        else:
            context['avg_diagnosis_accuracy'] = 0
            context['avg_treatment_clarity'] = 0
            context['avg_response_speed'] = 0
            context['avg_professionalism'] = 0
            context['avg_communication'] = 0
            context['avg_overall_satisfaction'] = 0
            context['overall_average'] = 0
            
            # النسب المئوية للحالة الفارغة
            context['diagnosis_accuracy_percent'] = 0
            context['treatment_clarity_percent'] = 0
            context['response_speed_percent'] = 0
            context['professionalism_percent'] = 0
            context['communication_percent'] = 0
            context['overall_satisfaction_percent'] = 0
            
            context['rating_distribution'] = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0}
        
        return context


class SendNotificationView(DoctorRequiredMixin, TemplateView):
    template_name = 'doctors/send_notification.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        doctor = get_object_or_404(Doctor, user=self.request.user)
        
        # جلب المرضى الذين تعامل معهم الطبيب
        context['my_patients'] = MedicalCase.objects.filter(
            doctor=doctor
        ).select_related('patient__user').values(
            'patient__id', 
            'patient__user__first_name', 
            'patient__user__last_name'
        ).distinct()
        
        context['doctor'] = doctor
        return context
    
    def post(self, request, *args, **kwargs):
        doctor = get_object_or_404(Doctor, user=request.user)
        
        title = request.POST.get('title')
        message = request.POST.get('message')
        patient_id = request.POST.get('patient_id')
        notification_type = request.POST.get('notification_type', 'doctor_message')
        
        if not title or not message:
            messages.error(request, _('يجب ملء جميع الحقول المطلوبة'))
            return redirect('doctors:send_notification')
        
        from patients.models import PatientNotification, Patient
        
        if patient_id == 'all':
            # إرسال لجميع المرضى
            my_patients = MedicalCase.objects.filter(doctor=doctor).values_list('patient', flat=True).distinct()
            patients = Patient.objects.filter(id__in=my_patients)
            
            for patient in patients:
                PatientNotification.objects.create(
                    patient=patient,
                    title=title,
                    message=message,
                    notification_type=notification_type,
                    sender_doctor=doctor
                )
            
            messages.success(request, f'تم إرسال الإشعار لـ {patients.count()} مريض')
        
        elif patient_id:
            # إرسال لمريض محدد
            try:
                patient = Patient.objects.get(id=patient_id)
                # التأكد من أن الطبيب تعامل مع هذا المريض
                if MedicalCase.objects.filter(doctor=doctor, patient=patient).exists():
                    PatientNotification.objects.create(
                        patient=patient,
                        title=title,
                        message=message,
                        notification_type=notification_type,
                        sender_doctor=doctor
                    )
                    messages.success(request, f'تم إرسال الإشعار للمريض {patient.user.first_name}')
                else:
                    messages.error(request, _('لا يمكنك إرسال إشعار لهذا المريض'))
            except Patient.DoesNotExist:
                messages.error(request, _('المريض غير موجود'))
        
        return redirect('doctors:send_notification')


class DoctorNotificationsView(DoctorRequiredMixin, TemplateView):
    template_name = 'doctors/notifications.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        doctor = get_object_or_404(Doctor, user=self.request.user)
        
        # استيراد إشعار الطبيب من تطبيق الأطباء نفسه
        from .models import DoctorNotification
        notifications = DoctorNotification.objects.filter(
            doctor=doctor
        ).order_by('-created_at')
        
        context['notifications'] = notifications
        context['unread_count'] = notifications.filter(is_read=False).count()
        context['doctor'] = doctor
        
        return context
    
    def post(self, request, *args, **kwargs):
        from .models import DoctorNotification
        from django.http import JsonResponse
        
        # تحديد الإشعار كمقروء
        notification_id = request.POST.get('notification_id')
        if notification_id:
            try:
                doctor = get_object_or_404(Doctor, user=request.user)
                notification = DoctorNotification.objects.get(
                    id=notification_id, 
                    doctor=doctor
                )
                notification.is_read = True
                notification.save()
                return JsonResponse({'success': True})
            except DoctorNotification.DoesNotExist:
                return JsonResponse({'success': False})
        
        # تحديد جميع الإشعارات كمقروءة
        if request.POST.get('mark_all_read'):
            doctor = get_object_or_404(Doctor, user=request.user)
            DoctorNotification.objects.filter(
                doctor=doctor, 
                is_read=False
            ).update(is_read=True)
            messages.success(request, _('تم تحديد جميع الإشعارات كمقروءة'))
        
        return redirect('doctors:notifications')
