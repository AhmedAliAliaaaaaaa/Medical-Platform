# Medical-Platform
المنصة الطبية المتكاملة

## النشر على Render

ملف `render.yaml` يجهز خدمة Django باستخدام PostgreSQL وDaphne. بعد ربط مستودع GitHub في Render:

1. أنشئ Redis وأضف قيمة `REDIS_URL` إلى متغيرات الخدمة إذا كانت WebSocket مطلوبة.
2. أضف `CSRF_TRUSTED_ORIGINS` و`CORS_ALLOWED_ORIGINS` مع عنوان الخدمة الكامل، مثل:
   `https://medical-platform-api.onrender.com`
3. أضف إعدادات البريد والدفع والتخزين الخارجي للملفات من لوحة Render.
4. لا ترفع ملف `.env` أو `db.sqlite3` إلى GitHub.

لبناء تطبيق Flutter بعنوان API المنشور:

```powershell
cd doctor_app
flutter build apk --release --dart-define=API_BASE_URL=https://medical-platform-api.onrender.com
```

يبقى التشغيل المحلي متاحًا دون `--dart-define`، بينما يستخدم البناء المنشور عنوان API الذي تحدده.
