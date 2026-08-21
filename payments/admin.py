from django.contrib import admin
from django.utils.translation import gettext as _
from .models import PaymentMethod, Payment, DoctorEarnings, WithdrawalRequest, PlatformSettings

@admin.register(PaymentMethod)
class PaymentMethodAdmin(admin.ModelAdmin):
    list_display = ['user', 'payment_type', 'card_number', 'is_default', 'is_active', 'created_at']
    list_filter = ['payment_type', 'is_default', 'is_active']
    search_fields = ['user__first_name', 'user__last_name', 'card_holder_name']
    readonly_fields = ['created_at']

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ['payment_id', 'user', 'amount', 'currency', 'status', 'payment_purpose', 'created_at']
    list_filter = ['status', 'payment_purpose', 'currency', 'created_at']
    search_fields = ['payment_id', 'user__first_name', 'user__last_name', 'transaction_id']
    readonly_fields = ['payment_id', 'created_at', 'updated_at']
    date_hierarchy = 'created_at'

@admin.register(DoctorEarnings)
class DoctorEarningsAdmin(admin.ModelAdmin):
    list_display = ['doctor', 'total_earnings', 'available_balance', 'pending_balance', 'consultation_fee']
    search_fields = ['doctor__user__first_name', 'doctor__user__last_name']
    readonly_fields = ['updated_at']

@admin.register(WithdrawalRequest)
class WithdrawalRequestAdmin(admin.ModelAdmin):
    list_display = ['doctor', 'amount', 'bank_name', 'status', 'requested_at']
    list_filter = ['status', 'bank_name', 'requested_at']
    search_fields = ['doctor__user__first_name', 'doctor__user__last_name', 'account_holder_name']
    readonly_fields = ['requested_at']
    actions = ['approve_requests', 'reject_requests']
    
    def approve_requests(self, request, queryset):
        queryset.update(status='approved')
        self.message_user(request, f"تم الموافقة على {queryset.count()} طلب سحب")
    approve_requests.short_description = "الموافقة على الطلبات المحددة"
    
    def reject_requests(self, request, queryset):
        queryset.update(status='rejected')
        self.message_user(request, f"تم رفض {queryset.count()} طلب سحب")
    reject_requests.short_description = "رفض الطلبات المحددة"

@admin.register(PlatformSettings)
class PlatformSettingsAdmin(admin.ModelAdmin):
    list_display = ['platform_commission_rate', 'minimum_withdrawal_amount', 'payment_gateway_enabled']
    readonly_fields = ['updated_at']
    
    def has_add_permission(self, request):
        # السماح بإنشاء سجل واحد فقط
        return not PlatformSettings.objects.exists()
    
    def has_delete_permission(self, request, obj=None):
        # منع حذف الإعدادات
        return False