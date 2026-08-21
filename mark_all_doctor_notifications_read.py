"""
Usage:
  python mark_all_doctor_notifications_read.py <doctor_email_or_username>
Marks all DoctorNotification for the specified doctor as read.
"""
import os
import django
import sys

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "medical_platform.settings")
django.setup()

from django.contrib.auth import get_user_model
from doctors.models import Doctor, DoctorNotification


def mark_all(ident: str):
    User = get_user_model()
    try:
        try:
            user = User.objects.get(email=ident)
        except User.DoesNotExist:
            user = User.objects.get(username=ident)
        doctor = Doctor.objects.get(user=user)
    except Exception as e:
        print(f"❌ Doctor not found for identifier: {ident}. Error: {e}")
        return 1

    qs = DoctorNotification.objects.filter(doctor=doctor, is_read=False)
    count = qs.update(is_read=True)
    print(f"✅ Marked {count} notifications as read for doctor {doctor}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Please provide doctor email or username, e.g.: python mark_all_doctor_notifications_read.py doctor@test.com")
        sys.exit(1)
    sys.exit(mark_all(sys.argv[1]))