from django.shortcuts import render, redirect
from django.views.generic import CreateView, TemplateView, UpdateView
from django.contrib.auth.views import LoginView as BaseLoginView, LogoutView as BaseLogoutView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.urls import reverse_lazy
from django.contrib.auth import login
from django.db import IntegrityError
from django.utils.translation import gettext as _
from .models import CustomUser
from doctors.models import Doctor
from patients.models import Patient
from .forms import CustomUserCreationForm, DoctorRegistrationForm, ExistingUserDoctorForm, ProfileUpdateForm
from .login_forms import CustomAuthenticationForm
from doctors.forms import EnhancedDoctorRegistrationForm

class RegisterView(CreateView):
    model = CustomUser
    form_class = CustomUserCreationForm
    template_name = 'accounts/register.html'
    success_url = reverse_lazy('accounts:login')
    
    def form_valid(self, form):
        user = form.save()
        # Create patient profile automatically
        if user.user_type == 'patient':
            Patient.objects.create(user=user)
        messages.success(self.request, _('تم إنشاء حسابك بنجاح! يمكنك الآن تسجيل الدخول.'))
        return super().form_valid(form)

class LoginView(BaseLoginView):
    template_name = 'accounts/login.html'
    redirect_authenticated_user = True
    
    def get_success_url(self):
        user = self.request.user
        if user.user_type == 'patient':
            return reverse_lazy('patients:dashboard')
        elif user.user_type == 'doctor':
            doctor = Doctor.objects.filter(user=user).first()
            if doctor and doctor.status == 'approved':
                return reverse_lazy('doctors:dashboard')
            else:
                return reverse_lazy('doctors:pending')
        elif user.user_type == 'admin':
            return reverse_lazy('admin_panel:dashboard')
        return reverse_lazy('core:home')
    
    def form_valid(self, form):
        user = form.get_user()
        if user.user_type == 'doctor':
            # للأطباء، اعرض الاسم الكامل مع اللقب
            full_name = f"د. {user.first_name} {user.last_name}".strip()
            messages.success(self.request, f'مرحباً بك {full_name}!')
        else:
            # للمرضى والمشرفين، اعرض الاسم الأول فقط
            messages.success(self.request, f'مرحباً بك {user.first_name or user.username}!')
        return super().form_valid(form)

class LogoutView(BaseLogoutView):
    next_page = reverse_lazy('core:home')
    
    def dispatch(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            if request.user.user_type == 'doctor':
                # للأطباء، اعرض الاسم الكامل مع اللقب
                full_name = f"د. {request.user.first_name} {request.user.last_name}".strip()
                messages.info(request, f'تم تسجيل خروج {full_name} بنجاح.')
            else:
                # للمرضى والمشرفين
                messages.info(request, f'تم تسجيل خروج {request.user.first_name or request.user.username} بنجاح.')
        return super().dispatch(request, *args, **kwargs)
    
    def get(self, request, *args, **kwargs):
        """Allow GET requests for logout"""
        return self.post(request, *args, **kwargs)

class DoctorRegisterView(TemplateView):
    template_name = 'accounts/doctor_register.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        if self.request.user.is_authenticated:
            # المستخدم مسجل دخول - استخدم نموذج المستخدم الموجود
            context['form'] = ExistingUserDoctorForm()
            context['is_existing_user'] = True
            context['user'] = self.request.user
        else:
            # مستخدم جديد - استخدم النموذج الكامل
            context['form'] = DoctorRegistrationForm()
            context['is_existing_user'] = False
            
        return context
    
    def post(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            # معالجة المستخدم الموجود
            return self._handle_existing_user(request)
        else:
            # معالجة المستخدم الجديد
            return self._handle_new_user(request)
    
    def _handle_existing_user(self, request):
        """معالجة طلب التسجيل كطبيب للمستخدم الموجود"""
        form = ExistingUserDoctorForm(request.POST, request.FILES)
        
        if form.is_valid():
            try:
                # التحقق من عدم وجود ملف طبيب مسبقاً
                if Doctor.objects.filter(user=request.user).exists():
                    messages.error(request, _('لديك طلب تسجيل كطبيب مسبقاً.'))
                    return redirect('doctors:pending')
                
                doctor = form.save(request.user)
                messages.success(request, _('تم إرسال طلبك للانضمام كطبيب. سيتم مراجعة ملفك من قبل الإدارة للقبول.'))
                return redirect('doctors:pending')
                
            except Exception as e:
                form.add_error(None, 'حدث خطأ أثناء إرسال الطلب. يرجى المحاولة مرة أخرى.')
        
        context = self.get_context_data()
        context['form'] = form
        context['is_existing_user'] = True
        return self.render_to_response(context)
    
    def _handle_new_user(self, request):
        """معالجة طلب التسجيل كطبيب للمستخدم الجديد"""
        form = DoctorRegistrationForm(request.POST, request.FILES)
        
        if form.is_valid():
            try:
                user = form.save()
                # Specify backend explicitly because multiple authentication backends are configured
                login(request, user, backend='accounts.authentication.CustomAuthenticationBackend')
                messages.success(request, _('تم إرسال طلبك للانضمام كطبيب. سيتم مراجعة ملفك من قبل الإدارة للقبول.'))
                return redirect('doctors:pending')
                
            except IntegrityError as e:
                if 'username' in str(e):
                    form.add_error('username', 'اسم المستخدم مستخدم بالفعل. يرجى اختيار اسم مستخدم آخر.')
                elif 'email' in str(e):
                    form.add_error('email', 'هذا البريد الإلكتروني مستخدم بالفعل.')
                else:
                    form.add_error(None, 'حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة مرة أخرى.')
        
        context = self.get_context_data()
        context['form'] = form
        context['is_existing_user'] = False
        return self.render_to_response(context)

class ProfileView(LoginRequiredMixin, UpdateView):
    model = CustomUser
    form_class = ProfileUpdateForm
    template_name = 'accounts/profile.html'
    success_url = reverse_lazy('accounts:profile')
    
    def get_object(self):
        return self.request.user
    
    def form_valid(self, form):
        messages.success(self.request, _('تم تحديث ملفك الشخصي بنجاح.'))
        return super().form_valid(form)

class ChangePasswordView(LoginRequiredMixin, TemplateView):
    template_name = 'accounts/change_password.html'

    def post(self, request, *args, **kwargs):
        from django.contrib.auth import update_session_auth_hash
        current = request.POST.get('current_password')
        new1 = request.POST.get('new_password1')
        new2 = request.POST.get('new_password2')
        if not request.user.check_password(current):
            messages.error(request, _('كلمة المرور الحالية غير صحيحة'))
            return redirect('accounts:change_password')
        if not new1 or new1 != new2:
            messages.error(request, _('كلمات المرور الجديدة غير متطابقة'))
            return redirect('accounts:change_password')
        request.user.set_password(new1)
        request.user.save()
        update_session_auth_hash(request, request.user)
        messages.success(request, _('تم تغيير كلمة المرور بنجاح'))
        return redirect('accounts:profile')

class SessionsView(LoginRequiredMixin, TemplateView):
    template_name = 'accounts/sessions.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        from django.contrib.sessions.models import Session
        from django.utils import timezone
        sessions = []
        for s in Session.objects.filter(expire_date__gte=timezone.now()):
            data = s.get_decoded()
            if data.get('_auth_user_id') == str(self.request.user.id):
                sessions.append({
                    'session_key': s.session_key,
                    'expire_date': s.expire_date,
                })
        context['sessions'] = sessions
        return context

    def post(self, request, *args, **kwargs):
        # إنهاء جلسة محددة أو جميع الجلسات
        from django.contrib.sessions.models import Session
        kill = request.POST.get('kill')
        if kill == 'all':
            Session.objects.all().delete()
            messages.success(request, _('تم إنهاء جميع الجلسات'))
        elif kill:
            Session.objects.filter(session_key=kill).delete()
            messages.success(request, _('تم إنهاء الجلسة المحددة'))
        return redirect('accounts:sessions')

class DeactivateAccountView(LoginRequiredMixin, TemplateView):
    template_name = 'accounts/deactivate.html'

    def post(self, request, *args, **kwargs):
        request.user.is_active = False
        request.user.save()
        messages.success(request, _('تم تعطيل حسابك. يمكنك التواصل مع الإدارة لإعادة التفعيل.'))
        return redirect('accounts:logout')

class DeleteAccountView(LoginRequiredMixin, TemplateView):
    template_name = 'accounts/delete_account.html'

    def post(self, request, *args, **kwargs):
        request.user.delete()
        messages.success(request, _('تم حذف حسابك نهائياً'))
        return redirect('core:home')


class EnhancedDoctorRegisterView(CreateView):
    """تسجيل طبيب جديد بالنموذج المحسن"""
    form_class = EnhancedDoctorRegistrationForm
    template_name = 'accounts/enhanced_doctor_register.html'
    success_url = reverse_lazy('doctors:pending')
    
    def form_valid(self, form):
        try:
            user = form.save()
            # Specify backend explicitly due to multiple authentication backends
            login(self.request, user, backend='accounts.authentication.CustomAuthenticationBackend')
            
            messages.success(
                self.request, 
                _('شكراً لك! تم إرسال طلب التسجيل بنجاح. سيتم الموافقة عليك من قبل الإدارة وبعدها ستتمكن من تسجيل الدخول باسمك الكامل وكلمة المرور.')
            )
            
            # إرسال إشعار للإدارة عند وصول طلب طبيب جديد
            try:
                from admin_panel.models import AdminNotification
                AdminNotification.objects.create(
                    title='طلب انضمام طبيب جديد',
                    message=f'طلب جديد من الطبيب: {user.get_full_name()} (@{user.username}) بانتظار المراجعة.',
                    notification_type='all_admins' if 'all_admins' in dict(getattr(AdminNotification, 'NOTIFICATION_TYPES', [])) else 'general',
                    created_by=user  # مبدئياً: منشئ الإشعار هو نفس المستخدم، يمكن تعديله لاحقاً لمستخدم إداري تلقائي
                )
            except Exception:
                pass
            
            return super().form_valid(form)
            
        except IntegrityError as e:
            if 'username' in str(e):
                form.add_error('username', 'اسم المستخدم مستخدم بالفعل. يرجى اختيار اسم مستخدم آخر.')
            elif 'email' in str(e):
                form.add_error('email', 'هذا البريد الإلكتروني مستخدم بالفعل.')
            elif 'license_number' in str(e):
                form.add_error('license_number', 'رقم الترخيص هذا مستخدم بالفعل.')
            else:
                form.add_error(None, 'حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة مرة أخرى.')
            
            return self.form_invalid(form)
        
        except Exception as e:
            form.add_error(None, f'حدث خطأ غير متوقع: {str(e)}')
            return self.form_invalid(form)
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['page_title'] = 'تسجيل طبيب جديد'
        context['page_description'] = 'انضم إلى شبكتنا من الأطباء المعتمدين'
        return context
