from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import MedicalCase, DoctorResponse, PatientNotification


def send_event(user_id, payload: dict):
    layer = get_channel_layer()
    if not layer:
        return
    async_to_sync(layer.group_send)(f"user_{user_id}", {"type": "push_event", "payload": payload})


@receiver(post_save, sender=DoctorResponse)
def on_doctor_response(sender, instance: DoctorResponse, created, **kwargs):
    try:
        case = instance.medical_case
        # Notify patient
        send_event(case.patient.user_id, {
            "type": "new_response",
            "case_id": case.id,
            "response_id": instance.id,
            "status": instance.status,
            "title": case.title,
        })
        # Notify doctor (optional)
        send_event(instance.doctor.user_id, {
            "type": "response_saved",
            "case_id": case.id,
            "response_id": instance.id,
            "status": instance.status,
        })
    except Exception:
        pass


@receiver(post_save, sender=MedicalCase)
def on_case_update(sender, instance: MedicalCase, created, **kwargs):
    try:
        if created:
            if instance.doctor_id:
                send_event(instance.doctor.user_id, {
                    "type": "new_case",
                    "case_id": instance.id,
                    "status": instance.status,
                    "title": instance.title,
                })
        else:
            if instance.doctor_id:
                send_event(instance.doctor.user_id, {
                    "type": "case_updated",
                    "case_id": instance.id,
                    "status": instance.status,
                })
    except Exception:
        pass


@receiver(post_save, sender=PatientNotification)
def on_notification(sender, instance: PatientNotification, created, **kwargs):
    try:
        if created:
            send_event(instance.patient.user_id, {
                "type": "notification",
                "id": instance.id,
                "notification_type": instance.notification_type,
                "case_id": instance.related_case_id,
                "is_read": instance.is_read,
                "title": instance.title,
                "message": instance.message,
            })
    except Exception:
        pass