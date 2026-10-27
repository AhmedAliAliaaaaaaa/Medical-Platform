from django.shortcuts import render, redirect, get_object_or_404
from django.views.generic import TemplateView, CreateView, UpdateView, DeleteView, UpdateView, DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.urls import reverse_lazy
from django.db.models import Count, Q
from django.utils import timezone
from django.http import JsonResponse, HttpResponse
from django.http import JsonResponse, HttpResponse
from django.utils.translation import gettext as _
from datetime import timedelta
from accounts.models import CustomUser
from doctors.models import Doctor
from patients.models import MedicalCase, Patient, DoctorResponse
from ..models import AdminNotification

class AdminRequiredMixin(LoginRequiredMixin):
    def dispatch(self, request, *args, **kwargs):
        if not request.user.is_authenticated or request.user.user_type != 'admin':
            messages.error(request, _('يجب أن تكون مشرفاً للوصول لهذه الصفحة.'))
            return redirect('accounts:login')
        return super().dispatch(request, *args, **kwargs)

class AdminDashboardView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/dashboard.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        # Statistics
        context['total_users'] = CustomUser.objects.count()
        context['total_patients'] = CustomUser.objects.filter(user_type='patient').count()
        context['total_doctors'] = Doctor.objects.filter(status='approved').count()
        context['pending_doctors'] = Doctor.objects.filter(status='pending').count()
        context['total_cases'] = MedicalCase.objects.count()
        context['pending_cases'] = MedicalCase.objects.filter(status='pending').count()
        context['completed_cases'] = MedicalCase.objects.filter(status='completed').count()
        
        # Recent activities
        context['recent_cases'] = MedicalCase.objects.order_by('-created_at')[:5]
        context['pending_doctor_requests'] = Doctor.objects.filter(status='pending')[:5]
        
        return context

class ManageDoctorsView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/manage_doctors.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['pending_doctors'] = Doctor.objects.filter(status='pending').select_related('user')
        context['approved_doctors'] = Doctor.objects.filter(status='approved').select_related('user')
        context['rejected_doctors'] = Doctor.objects.filter(status='rejected').select_related('user')
        context['available_doctors'] = Doctor.objects.filter(
            status='approved', is_available=True
        ).select_related('user')
        return context

class ApproveDoctorView(AdminRequiredMixin, TemplateView):
    def post(self, request, *args, **kwargs):
        doctor_id = kwargs['doctor_id']
        doctor = get_object_or_404(Doctor, id=doctor_id)
        doctor.status = 'approved'
        doctor.save()
        
        # Activate the user account
        user = doctor.user
        user.is_active = True
        user.save()
        
        messages.success(request, f'تم قبول د. {doctor.user.first_name} {doctor.user.last_name}')
        return redirect('admin_panel:manage_doctors')

class RejectDoctorView(AdminRequiredMixin, TemplateView):
    def post(self, request, *args, **kwargs):
        doctor_id = kwargs['doctor_id']
        doctor = get_object_or_404(Doctor, id=doctor_id)
        doctor.status = 'rejected'
        doctor.save()

        # Deactivate the user account
        user = doctor.user
        user.is_active = False
        user.save()

        messages.warning(request, f'تم رفض د. {doctor.user.first_name} {doctor.user.last_name}')
        return redirect('admin_panel:manage_doctors')

class ManageCasesView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/manage_cases.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['all_cases'] = MedicalCase.objects.select_related(
            'patient__user', 'doctor__user'
        ).prefetch_related('attachments', 'responses').select_related(
            'patient__user', 'doctor__user'
        ).prefetch_related('attachments', 'responses').order_by('-created_at')
        
        # Statistics
        context['pending_cases'] = MedicalCase.objects.filter(status='pending').count()
        context['in_progress_cases'] = MedicalCase.objects.filter(status='in_progress').count()
        context['completed_cases'] = MedicalCase.objects.filter(status='completed').count()
        context['cancelled_cases'] = MedicalCase.objects.filter(status='cancelled').count()
        
        return context

class CaseDetailView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/case_detail.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        case_id = kwargs['case_id']
        case = get_object_or_404(MedicalCase.objects.select_related(
            'patient__user', 'doctor__user'
        ).prefetch_related('attachments', 'responses'), id=case_id)
        
        context['case'] = case
        context['available_doctors'] = Doctor.objects.filter(
            status='approved', is_available=True
        ).select_related('user')
        
        return context

class UpdateCaseView(AdminRequiredMixin, UpdateView):
    model = MedicalCase
    fields = ['title', 'description', 'priority', 'status', 'doctor']
    template_name = 'admin_panel/update_case.html'
    pk_url_kwarg = 'case_id'
    
    def get_success_url(self):
        messages.success(self.request, _('تم تحديث الحالة بنجاح!'))
        return reverse_lazy('admin_panel:manage_cases')
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['available_doctors'] = Doctor.objects.filter(
            status='approved', is_available=True
        ).select_related('user')
        return context

class DeleteCaseView(AdminRequiredMixin, DeleteView):
    model = MedicalCase
    pk_url_kwarg = 'case_id'
    success_url = reverse_lazy('admin_panel:manage_cases')
    
    def delete(self, request, *args, **kwargs):
        messages.success(request, _('تم حذف الحالة بنجاح!'))
        return super().delete(request, *args, **kwargs)

class DoctorDetailView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/doctor_detail.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        doctor_id = kwargs['doctor_id']
        doctor = get_object_or_404(Doctor.objects.select_related('user'), id=doctor_id)
        
        context['doctor'] = doctor
        context['doctor_cases'] = MedicalCase.objects.filter(
            doctor=doctor
        ).select_related('patient__user').order_by('-created_at')[:10]
        context['doctor_responses'] = DoctorResponse.objects.filter(
            doctor=doctor
        ).select_related('medical_case__patient__user').order_by('-created_at')[:10]
        
        return context

class UpdateDoctorView(AdminRequiredMixin, UpdateView):
    model = Doctor
    fields = ['specialization', 'license_number', 'experience_years', 'bio', 
              'consultation_fee', 'is_available', 'status', 'country']
    template_name = 'admin_panel/update_doctor.html'
    pk_url_kwarg = 'doctor_id'
    
    def get_success_url(self):
        messages.success(self.request, _('تم تحديث بيانات الطبيب بنجاح!'))
        return reverse_lazy('admin_panel:manage_doctors')

class DeleteDoctorView(AdminRequiredMixin, DeleteView):
    model = Doctor
    pk_url_kwarg = 'doctor_id'
    success_url = reverse_lazy('admin_panel:manage_doctors')
    
    def delete(self, request, *args, **kwargs):
        messages.success(request, _('تم حذف الطبيب بنجاح!'))
        return super().delete(request, *args, **kwargs)

class ResponsesView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/responses.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['responses'] = DoctorResponse.objects.select_related(
            'doctor__user', 'medical_case__patient__user'
        ).prefetch_related('attachments').order_by('-created_at')
        
        return context

class ResponseDetailView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/response_detail.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        response_id = kwargs['response_id']
        response = get_object_or_404(DoctorResponse.objects.select_related(
            'doctor__user', 'medical_case__patient__user'
        ), id=response_id)
        
        context['response'] = response
        return context

class AssignDoctorView(AdminRequiredMixin, TemplateView):
    def post(self, request, *args, **kwargs):
        case_id = kwargs['case_id']
        doctor_id = request.POST.get('doctor_id')
        
        case = get_object_or_404(MedicalCase, id=case_id)
        doctor = get_object_or_404(Doctor, id=doctor_id, status='approved')
        
        case.doctor = doctor
        case.status = 'in_progress'
        case.save()
        
        messages.success(request, f'تم تعيين د. {doctor.user.get_full_name()} للحالة بنجاح!')
        return redirect('admin_panel:manage_cases')

class ManageUsersView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/manage_users.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        # جلب جميع المستخدمين مع العلاقات المرتبطة
        context['all_users'] = CustomUser.objects.select_related('patient', 'doctor').order_by('-date_joined')
        
        # الإحصائيات
        context['total_users'] = CustomUser.objects.count()
        context['patients_count'] = CustomUser.objects.filter(user_type='patient').count()
        context['doctors_count'] = CustomUser.objects.filter(user_type='doctor').count()
        context['admins_count'] = CustomUser.objects.filter(user_type='admin').count()
        
        return context

class UpdateUserView(AdminRequiredMixin, UpdateView):
    model = CustomUser
    template_name = 'admin_panel/update_user.html'
    fields = ['first_name', 'last_name', 'email', 'phone_number', 'user_type', 'is_active']
    success_url = reverse_lazy('admin_panel:manage_users')
    
    def form_valid(self, form):
        messages.success(self.request, f'تم تحديث بيانات المستخدم {form.instance.get_full_name()} بنجاح!')
        return super().form_valid(form)

class DeleteUserView(AdminRequiredMixin, DeleteView):
    model = CustomUser
    template_name = 'admin_panel/delete_user.html'
    success_url = reverse_lazy('admin_panel:manage_users')
    
    def get_queryset(self):
        # منع حذف المشرفين
        return CustomUser.objects.exclude(user_type='admin')
    
    def delete(self, request, *args, **kwargs):
        user = self.get_object()
        messages.success(request, f'تم حذف المستخدم {user.get_full_name()} بنجاح!')
        return super().delete(request, *args, **kwargs)

class NotificationsView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/notifications.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['notifications'] = AdminNotification.objects.select_related(
            'created_by',
            'related_patient__user',
            'related_doctor__user',
            'related_case',
            'related_response',
        ).order_by('-created_at')
        return context

class ReplyToComplaintView(AdminRequiredMixin, TemplateView):
    def post(self, request, *args, **kwargs):
        notification = get_object_or_404(
            AdminNotification.objects.select_related(
                'related_patient__user', 'related_doctor__user'
            ),
            id=kwargs['notification_id'],
        )
        reply = request.POST.get('reply', '').strip()
        if notification.notification_type not in (
            'patient_complaint',
            'doctor_complaint',
            'doctor_message',
        ):
            messages.error(request, _('لا يمكن الرد على هذا الإشعار.'))
        elif not reply:
            messages.error(request, _('يرجى كتابة نص الرد.'))
        elif notification.related_patient:
            from patients.models import PatientNotification
            PatientNotification.objects.create(
                patient=notification.related_patient,
                title=f'رد الإدارة: {notification.title}',
                message=reply,
                notification_type='admin',
                sender_admin=request.user,
            )
            messages.success(request, _('تم إرسال الرد إلى المريض بنجاح.'))
        elif notification.related_doctor:
            from doctors.models import DoctorNotification
            DoctorNotification.objects.create(
                doctor=notification.related_doctor,
                title=f'رد الإدارة: {notification.title}',
                message=reply,
                notification_type='admin',
                sender_admin=request.user,
            )
            messages.success(request, _('تم إرسال الرد إلى الطبيب بنجاح.'))
        else:
            messages.error(request, _('لا يوجد صاحب شكوى مرتبط بهذا الإشعار.'))
        return redirect('admin_panel:notifications')

class SendNotificationView(AdminRequiredMixin, TemplateView):
    """إرسال إشعار جديد للمستخدمين"""
    template_name = 'admin_panel/send_notification.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['doctors'] = CustomUser.objects.filter(user_type='doctor')
        context['patients'] = CustomUser.objects.filter(user_type='patient')
        return context
    
    def post(self, request, *args, **kwargs):
        # جمع بيانات الإشعار من النموذج
        title = request.POST.get('title', '').strip()
        message = request.POST.get('message', '').strip()
        notification_type = request.POST.get('notification_type', '').strip()
        target_user_id = request.POST.get('target_user', '').strip()
        
        # التحقق من صحة البيانات
        if not title or not message or not notification_type:
            messages.error(request, _('يرجى ملء جميع الحقول المطلوبة'))
            return redirect('admin_panel:send_notification')
        
        # إنشاء الإشعار الإداري
        admin_notification = AdminNotification.objects.create(
            title=title,
            message=message,
            notification_type=notification_type,
            created_by=request.user
        )
        
        # إرسال الإشعارات للمستخدمين
        self.send_notifications(
            title=title,
            message=message,
            notification_type=notification_type,
            target_user_id=target_user_id,
            admin_user=request.user
        )
        
        messages.success(request, _('تم إرسال الإشعار بنجاح!'))
        return redirect('admin_panel:notifications')
    
    def send_notifications(self, title, message, notification_type, target_user_id=None, admin_user=None):
        """إرسال إشعارات للمستخدمين بناءً على نوع الإشعار"""
        from patients.models import PatientNotification, Patient
        from doctors.models import DoctorNotification, Doctor
        
        if notification_type == 'general' or notification_type == 'all_users':
            # إرسال لجميع المرضى
            patients = Patient.objects.all()
            for patient in patients:
                PatientNotification.objects.create(
                    patient=patient,
                    title=title,
                    message=message,
                    notification_type='admin',
                    sender_admin=admin_user
                )
            # إرسال لجميع الأطباء المعتمدين
            doctors = Doctor.objects.filter(status='approved')
            for doctor in doctors:
                DoctorNotification.objects.create(
                    doctor=doctor,
                    title=title,
                    message=message,
                    notification_type='admin',
                    sender_admin=admin_user
                )
        
        elif notification_type == 'doctors':
            # إرسال للأطباء فقط
            doctors = Doctor.objects.filter(status='approved')
            for doctor in doctors:
                DoctorNotification.objects.create(
                    doctor=doctor,
                    title=title,
                    message=message,
                    notification_type='admin',
                    sender_admin=admin_user
                )
        
        elif notification_type == 'patients':
            # إرسال للمرضى فقط
            patients = Patient.objects.all()
            for patient in patients:
                PatientNotification.objects.create(
                    patient=patient,
                    title=title,
                    message=message,
                    notification_type='admin',
                    sender_admin=admin_user
                )
        
        elif notification_type == 'specific' and target_user_id:
            # إرسال لمستخدم محدد
            try:
                target_user = CustomUser.objects.get(id=target_user_id)
                if target_user.user_type == 'patient':
                    patient = Patient.objects.get(user=target_user)
                    PatientNotification.objects.create(
                        patient=patient,
                        title=title,
                        message=message,
                        notification_type='admin',
                        sender_admin=admin_user
                    )
                elif target_user.user_type == 'doctor':
                    doctor = Doctor.objects.get(user=target_user)
                    DoctorNotification.objects.create(
                        doctor=doctor,
                        title=title,
                        message=message,
                        notification_type='admin',
                        sender_admin=admin_user
                    )
            except (CustomUser.DoesNotExist, Patient.DoesNotExist, Doctor.DoesNotExist):
                pass

class StatisticsView(AdminRequiredMixin, TemplateView):
    template_name = 'admin_panel/statistics.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        # General statistics
        context['total_users'] = CustomUser.objects.count()
        context['total_patients'] = CustomUser.objects.filter(user_type='patient').count()
        context['total_doctors'] = Doctor.objects.filter(status='approved').count()
        context['total_cases'] = MedicalCase.objects.count()
        context['pending_doctors'] = Doctor.objects.filter(status='pending').count()
        
        # Monthly statistics
        now = timezone.now()
        last_month = now - timedelta(days=30)
        
        context['monthly_users'] = CustomUser.objects.filter(date_joined__gte=last_month).count()
        context['monthly_cases'] = MedicalCase.objects.filter(created_at__gte=last_month).count()
        context['monthly_doctors'] = Doctor.objects.filter(created_at__gte=last_month).count()
        context['monthly_responses'] = DoctorResponse.objects.filter(created_at__gte=last_month).count()
        
        # Cases statistics
        context['cases_by_status'] = {
            'pending': MedicalCase.objects.filter(status='pending').count(),
            'in_progress': MedicalCase.objects.filter(status='in_progress').count(),
            'completed': MedicalCase.objects.filter(status='completed').count(),
            'cancelled': MedicalCase.objects.filter(status='cancelled').count(),
        }
        
        # Doctor specializations
        from django.db.models import Count
        context['doctors_by_specialization'] = Doctor.objects.values('specialization').annotate(
            count=Count('specialization')
        ).order_by('-count')
        
        # Recent activity
        context['recent_cases'] = MedicalCase.objects.order_by('-created_at')[:10]
        context['recent_users'] = CustomUser.objects.order_by('-date_joined')[:10]
        
        return context


class ExportReportsView(AdminRequiredMixin, TemplateView):
    """تصدير التقارير بصيغ مختلفة"""
    
    def get(self, request, *args, **kwargs):
        export_type = request.GET.get('type', 'users')
        format_type = request.GET.get('format', 'csv')
        
        if export_type == 'users':
            return self.export_users_report(format_type)
        elif export_type == 'cases':
            return self.export_cases_report(format_type)
        elif export_type == 'doctors':
            return self.export_doctors_report(format_type)
        elif export_type == 'statistics':
            return self.export_statistics_report(format_type)
        else:
            messages.error(request, _('نوع التقرير غير صحيح'))
            return redirect('admin_panel:statistics')
    
    def export_users_report(self, format_type):
        """تصدير تقرير المستخدمين"""
        import csv
        from django.http import HttpResponse
        import json
        
        users = CustomUser.objects.all().order_by('-date_joined')
        
        if format_type == 'csv':
            response = HttpResponse(content_type='text/csv; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="users_report.csv"'
            response.write('\ufeff')  # BOM for UTF-8
            
            writer = csv.writer(response)
            writer.writerow(['الرقم', 'الاسم الأول', 'الاسم الأخير', 'البريد الإلكتروني', 'نوع المستخدم', 'تاريخ التسجيل', 'آخر دخول', 'الحالة'])
            
            for user in users:
                writer.writerow([
                    user.id,
                    user.first_name,
                    user.last_name,
                    user.email,
                    user.get_user_type_display(),
                    user.date_joined.strftime('%Y-%m-%d %H:%M'),
                    user.last_login.strftime('%Y-%m-%d %H:%M') if user.last_login else 'لم يدخل',
                    'نشط' if user.is_active else 'معطل'
                ])
            
            return response
            
        elif format_type == 'json':
            response = HttpResponse(content_type='application/json; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="users_report.json"'
            
            users_data = []
            for user in users:
                users_data.append({
                    'id': user.id,
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                    'email': user.email,
                    'user_type': user.user_type,
                    'date_joined': user.date_joined.isoformat(),
                    'last_login': user.last_login.isoformat() if user.last_login else None,
                    'is_active': user.is_active
                })
            
            response.write(json.dumps(users_data, ensure_ascii=False, indent=2))
            return response
        elif format_type in ('xlsx', 'xls', 'excel'):
            # HTML table trick for Excel compatibility
            response = HttpResponse(content_type='application/vnd.ms-excel; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="users_report.xls"'
            response.write('\ufeff')
            rows_html = ''.join([
                f"<tr><td>{u.id}</td><td>{u.first_name}</td><td>{u.last_name}</td><td>{u.email}</td><td>{u.get_user_type_display()}</td><td>{u.date_joined.strftime('%Y-%m-%d %H:%M')}</td><td>{u.last_login.strftime('%Y-%m-%d %H:%M') if u.last_login else 'لم يدخل'}</td><td>{'نشط' if u.is_active else 'معطل'}</td></tr>"
                for u in users
            ])
            html = f"""
                <html>
                <head><meta charset='utf-8'></head>
                <body>
                    <table border="1">
                        <thead>
                            <tr>
                                <th>الرقم</th><th>الاسم الأول</th><th>الاسم الأخير</th><th>البريد الإلكتروني</th>
                                <th>نوع المستخدم</th><th>تاريخ التسجيل</th><th>آخر دخول</th><th>الحالة</th>
                            </tr>
                        </thead>
                        <tbody>{rows_html}</tbody>
                    </table>
                </body>
                </html>
            """
            response.write(html)
            return response
        elif format_type == 'pdf':
            # لا مكتبات خارجية: ننصح بالطباعة إلى PDF من واجهة الإحصائيات
            messages.info(self.request, _('لإنشاء PDF، استخدم زر الطباعة واختر "الحفظ كملف PDF"'))
            return redirect('admin_panel:statistics')
    
    def export_cases_report(self, format_type):
        """تصدير تقرير الحالات الطبية"""
        import csv
        from django.http import HttpResponse
        import json
        
        cases = MedicalCase.objects.select_related('patient__user', 'doctor__user').order_by('-created_at')
        
        if format_type == 'csv':
            response = HttpResponse(content_type='text/csv; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="cases_report.csv"'
            response.write('\ufeff')
            
            writer = csv.writer(response)
            writer.writerow(['رقم الحالة', 'عنوان الحالة', 'المريض', 'الطبيب', 'الحالة', 'الأولوية', 'تاريخ الإنشاء', 'تاريخ التحديث'])
            
            for case in cases:
                writer.writerow([
                    case.id,
                    case.title,
                    f"{case.patient.user.first_name} {case.patient.user.last_name}",
                    f"د. {case.doctor.user.first_name} {case.doctor.user.last_name}" if case.doctor else 'لم يتم التعيين',
                    case.get_status_display(),
                    case.get_priority_display(),
                    case.created_at.strftime('%Y-%m-%d %H:%M'),
                    case.updated_at.strftime('%Y-%m-%d %H:%M')
                ])
            
            return response
            
        elif format_type == 'json':
            response = HttpResponse(content_type='application/json; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="cases_report.json"'
            
            cases_data = []
            for case in cases:
                cases_data.append({
                    'id': case.id,
                    'title': case.title,
                    'patient': f"{case.patient.user.first_name} {case.patient.user.last_name}",
                    'doctor': f"د. {case.doctor.user.first_name} {case.doctor.user.last_name}" if case.doctor else None,
                    'status': case.status,
                    'priority': case.priority,
                    'created_at': case.created_at.isoformat(),
                    'updated_at': case.updated_at.isoformat()
                })
            
            response.write(json.dumps(cases_data, ensure_ascii=False, indent=2))
            return response
        elif format_type in ('xlsx', 'xls', 'excel'):
            response = HttpResponse(content_type='application/vnd.ms-excel; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="cases_report.xls"'
            response.write('\ufeff')
            rows_html = ''.join([
                f"<tr><td>{c.id}</td><td>{c.title}</td><td>{c.patient.user.first_name} {c.patient.user.last_name}</td><td>{('د. ' + c.doctor.user.first_name + ' ' + c.doctor.user.last_name) if c.doctor else 'لم يتم التعيين'}</td><td>{c.get_status_display()}</td><td>{c.get_priority_display()}</td><td>{c.created_at.strftime('%Y-%m-%d %H:%M')}</td><td>{c.updated_at.strftime('%Y-%m-%d %H:%M')}</td></tr>"
                for c in cases
            ])
            html = f"""
                <html>
                <head><meta charset='utf-8'></head>
                <body>
                    <table border="1">
                        <thead>
                            <tr>
                                <th>رقم الحالة</th><th>عنوان الحالة</th><th>المريض</th><th>الطبيب</th>
                                <th>الحالة</th><th>الأولوية</th><th>تاريخ الإنشاء</th><th>تاريخ التحديث</th>
                            </tr>
                        </thead>
                        <tbody>{rows_html}</tbody>
                    </table>
                </body>
                </html>
            """
            response.write(html)
            return response
        elif format_type == 'pdf':
            messages.info(self.request, _('لإنشاء PDF، استخدم زر الطباعة واختر "الحفظ كملف PDF"'))
            return redirect('admin_panel:statistics')
    
    def export_doctors_report(self, format_type):
        """تصدير تقرير الأطباء"""
        import csv
        from django.http import HttpResponse
        import json
        
        doctors = Doctor.objects.select_related('user').order_by('-created_at')
        
        if format_type == 'csv':
            response = HttpResponse(content_type='text/csv; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="doctors_report.csv"'
            response.write('\ufeff')
            
            writer = csv.writer(response)
            writer.writerow(['الرقم', 'اسم الطبيب', 'التخصص', 'سنوات الخبرة', 'التقييم', 'عدد التقييمات', 'الحالة', 'تاريخ التسجيل'])
            
            for doctor in doctors:
                writer.writerow([
                    doctor.id,
                    f"د. {doctor.user.first_name} {doctor.user.last_name}",
                    doctor.get_specialization_display(),
                    doctor.experience_years,
                    doctor.rating,
                    doctor.total_reviews,
                    doctor.get_status_display(),
                    doctor.created_at.strftime('%Y-%m-%d %H:%M')
                ])
            
            return response
        elif format_type in ('xlsx', 'xls', 'excel'):
            response = HttpResponse(content_type='application/vnd.ms-excel; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="doctors_report.xls"'
            response.write('\ufeff')
            rows_html = ''.join([
                f"<tr><td>{d.id}</td><td>د. {d.user.first_name} {d.user.last_name}</td><td>{d.get_specialization_display()}</td><td>{d.experience_years}</td><td>{d.rating}</td><td>{d.total_reviews}</td><td>{d.get_status_display()}</td><td>{d.created_at.strftime('%Y-%m-%d %H:%M')}</td></tr>"
                for d in doctors
            ])
            html = f"""
                <html>
                <head><meta charset='utf-8'></head>
                <body>
                    <table border="1">
                        <thead>
                            <tr>
                                <th>الرقم</th><th>اسم الطبيب</th><th>التخصص</th><th>سنوات الخبرة</th>
                                <th>التقييم</th><th>عدد التقييمات</th><th>الحالة</th><th>تاريخ التسجيل</th>
                            </tr>
                        </thead>
                        <tbody>{rows_html}</tbody>
                    </table>
                </body>
                </html>
            """
            response.write(html)
            return response
        elif format_type == 'json':
            response = HttpResponse(content_type='application/json; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="doctors_report.json"'
            doctors_data = []
            for d in doctors:
                doctors_data.append({
                    'id': d.id,
                    'name': f"د. {d.user.first_name} {d.user.last_name}",
                    'specialization': d.specialization,
                    'experience_years': d.experience_years,
                    'rating': float(d.rating),
                    'total_reviews': d.total_reviews,
                    'status': d.status,
                    'created_at': d.created_at.isoformat(),
                })
            response.write(json.dumps(doctors_data, ensure_ascii=False, indent=2))
            return response
    
    def export_statistics_report(self, format_type):
        """تصدير تقرير الإحصائيات العامة"""
        import csv
        from django.http import HttpResponse
        import json
        from datetime import datetime
        
        # جمع الإحصائيات
        stats = {
            'report_date': datetime.now().isoformat(),
            'total_users': CustomUser.objects.count(),
            'total_patients': CustomUser.objects.filter(user_type='patient').count(),
            'total_doctors': Doctor.objects.filter(status='approved').count(),
            'pending_doctors': Doctor.objects.filter(status='pending').count(),
            'total_cases': MedicalCase.objects.count(),
            'pending_cases': MedicalCase.objects.filter(status='pending').count(),
            'completed_cases': MedicalCase.objects.filter(status='completed').count(),
            'in_progress_cases': MedicalCase.objects.filter(status='in_progress').count(),
        }
        
        if format_type == 'json':
            response = HttpResponse(content_type='application/json; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="statistics_report.json"'
            response.write(json.dumps(stats, ensure_ascii=False, indent=2))
            return response
        
        elif format_type == 'csv':
            response = HttpResponse(content_type='text/csv; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="statistics_report.csv"'
            response.write('\ufeff')
            
            writer = csv.writer(response)
            writer.writerow(['المؤشر', 'القيمة'])
            
            writer.writerow(['تاريخ التقرير', datetime.now().strftime('%Y-%m-%d %H:%M')])
            writer.writerow(['إجمالي المستخدمين', stats['total_users']])
            writer.writerow(['عدد المرضى', stats['total_patients']])
            writer.writerow(['عدد الأطباء المعتمدين', stats['total_doctors']])
            writer.writerow(['الأطباء في الانتظار', stats['pending_doctors']])
            writer.writerow(['إجمالي الحالات', stats['total_cases']])
            writer.writerow(['الحالات المعلقة', stats['pending_cases']])
            writer.writerow(['الحالات المكتملة', stats['completed_cases']])
            writer.writerow(['الحالات قيد المراجعة', stats['in_progress_cases']])
            
            return response
        elif format_type in ('xlsx', 'xls', 'excel'):
            response = HttpResponse(content_type='application/vnd.ms-excel; charset=utf-8')
            response['Content-Disposition'] = 'attachment; filename="statistics_report.xls"'
            response.write('\ufeff')
            rows_html = ''.join([
                f"<tr><td>إجمالي المستخدمين</td><td>{stats['total_users']}</td></tr>",
                f"<tr><td>عدد المرضى</td><td>{stats['total_patients']}</td></tr>",
                f"<tr><td>عدد الأطباء المعتمدين</td><td>{stats['total_doctors']}</td></tr>",
                f"<tr><td>الأطباء في الانتظار</td><td>{stats['pending_doctors']}</td></tr>",
                f"<tr><td>إجمالي الحالات</td><td>{stats['total_cases']}</td></tr>",
                f"<tr><td>الحالات المعلقة</td><td>{stats['pending_cases']}</td></tr>",
                f"<tr><td>الحالات المكتملة</td><td>{stats['completed_cases']}</td></tr>",
                f"<tr><td>الحالات قيد المراجعة</td><td>{stats['in_progress_cases']}</td></tr>",
            ])
            html = f"""
                <html>
                <head><meta charset='utf-8'></head>
                <body>
                    <table border="1">
                        <thead>
                            <tr><th>المؤشر</th><th>القيمة</th></tr>
                        </thead>
                        <tbody>
                            <tr><td>تاريخ التقرير</td><td>{datetime.now().strftime('%Y-%m-%d %H:%M')}</td></tr>
                            {rows_html}
                        </tbody>
                    </table>
                </body>
                </html>
            """
            response.write(html)
            return response
        elif format_type == 'pdf':
            messages.info(self.request, _('لإنشاء PDF، استخدم زر الطباعة واختر "الحفظ كملف PDF"'))
            return redirect('admin_panel:statistics')


class TestAdminView(TemplateView):
    """صفحة اختبار لعرض بيانات الإدارة"""
    template_name = 'test_admin.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        # Statistics
        context['total_users'] = CustomUser.objects.count()
        context['total_patients'] = CustomUser.objects.filter(user_type='patient').count()
        context['total_doctors'] = Doctor.objects.filter(status='approved').count()
        context['pending_doctors'] = Doctor.objects.filter(status='pending').count()
        context['total_cases'] = MedicalCase.objects.count()
        context['pending_cases'] = MedicalCase.objects.filter(status='pending').count()
        context['completed_cases'] = MedicalCase.objects.filter(status='completed').count()
        
        # Recent activities
        context['recent_cases'] = MedicalCase.objects.order_by('-created_at')[:5]
        context['pending_doctor_requests'] = Doctor.objects.filter(status='pending').select_related('user')
        
        return context

class TestPageView(AdminRequiredMixin, TemplateView):
    """صفحة اختبار لوحة الإدارة الجديدة"""
    template_name = 'admin_panel/test_page.html'

# Import doctor management views
from . import doctor_management_views
