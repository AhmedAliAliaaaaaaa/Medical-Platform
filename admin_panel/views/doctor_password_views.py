from django.shortcuts import get_object_or_404
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.utils.translation import gettext as _
from doctors.models import Doctor

@staff_member_required
@login_required
@require_http_methods(["GET"])
def get_doctor_password(request, doctor_id):
    """جلب كلمة مرور الطبيب (للعرض فقط)"""
    try:
        doctor = get_object_or_404(Doctor, id=doctor_id)

        # Since Django stores hashed passwords, we can't retrieve the original
        # Instead, we'll return a message indicating this
        return JsonResponse({
            'success': True,
            'password': '••••••••',
            'message': _('كلمة المرور الأصلية مشفرة ولا يمكن عرضها. يمكنك إعادة تعيين كلمة مرور جديدة.')
        })

    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        })
