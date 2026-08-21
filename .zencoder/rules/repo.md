# Repository Guide

- Name: medical_platform
- Stack:
  - Backend: Django 5 + DRF + SimpleJWT + Channels (ASGI)
  - Frontend (mobile): Flutter (doctor_app) with Dio, web_socket_channel
  - DB: SQLite (dev)

## Key Apps

- accounts: CustomUser and auth backends
- patients: cases, responses, notifications (+ signals -> WS)
- doctors, payments, admin_panel, core

## Entry points

- manage.py
- medical_platform/settings.py
- medical_platform/asgi.py (Channels routing)
- medical_platform/wsgi.py

## Realtime

- Channels enabled (InMemoryChannelLayer for dev)
- JWTAuth WS middleware: medical_platform/jwt_channels_middleware.py
- WS routing: patients/routing.py -> ws/stream/
- Consumer: patients/ws*consumers.py (group per user: user*{id})
- Signals: patients/signals.py emit events on model changes

## Flutter integration

- BaseApiService attaches Authorization: Bearer <JWT>
- WebSocketService connects to ws(s)://<host>/ws/stream/?token=<JWT>
- Doctor dashboard listens and refreshes on events

## Local run (dev)

1. Install deps: pip install -r requirements.txt && pip install channels daphne
2. Run ASGI server: daphne -b 0.0.0.0 -p 8000 medical_platform.asgi:application
3. Flutter: flutter pub get; flutter run

## Notes127

- For production use Redis channel layer (channels_redis) and secure SECRET_KEY.
- Update CORS/ALLOWED_HOSTS accordingly.
  تمام ✅، إليك الدليل نفسه مترجم بالكامل للعربي بشكل واضح وجاهز للنسخ:

دليل المستودع (Repository Guide)

الاسم: medical_platform

المكدس التقني (Stack):

Backend: Django 5 + DRF + SimpleJWT + Channels (ASGI)

Frontend (تطبيق الجوال): Flutter (doctor_app) مع Dio و web_socket_channel

قاعدة البيانات: SQLite (للتطوير)

التطبيقات الرئيسية (Key Apps)

accounts: إدارة المستخدمين والمصادقة المخصصة (CustomUser و auth backends)

patients: الحالات، الردود، الإشعارات (+ signals لإرسال أحداث WebSocket)

doctors, payments, admin_panel, core → وظائف إضافية مختلفة (لوحة تحكم، المدفوعات، إلخ)

نقاط الدخول (Entry points)

manage.py → نقطة البداية لتشغيل أوامر Django

settings.py → إعدادات المشروع

asgi.py → إعداد ASGI لـ Channels (الـ WebSocket)

wsgi.py → إعداد WSGI لتشغيل السيرفر التقليدي (HTTP)

الوقت الحقيقي (Realtime)

Channels مفعل → يستخدم InMemoryChannelLayer للتطوير (غير مناسب للإنتاج)

JWTAuth WS middleware: jwt_channels_middleware.py يتحقق من توكن JWT عند فتح WebSocket

توجيه WebSocket: patients/routing.py → endpoint: /ws/stream/

Consumer: في patients/ws*consumers.py، لكل مستخدم مجموعة خاصة (group) باسم user*{id}

Signals: عند تغيّر أي نموذج (مثل إضافة حالة جديدة)، يُرسل حدث WebSocket لتحديث التطبيق فوراً

التكامل مع Flutter

BaseApiService → يضيف Authorization: Bearer <JWT> لكل طلب HTTP

WebSocketService → يتصل بـ: ws(s)://<host>/ws/stream/?token=<JWT>

لوحة الطبيب (Doctor dashboard) → تستمع للأحداث وتحدّث البيانات مباشرة عند أي تغيير

التشغيل محلياً (للتطوير)

تثبيت المتطلبات:

pip install -r requirements.txt
pip install channels daphne

تشغيل سيرفر ASGI باستخدام Daphne:

daphne -b 0.0.0.0 -p 8000 medical_platform.asgi:application

تشغيل Flutter:

flutter pub get
flutter run

ملاحظات

للإنتاج، استخدم Redis channel layer (channels_redis) بدل InMemoryChannelLayer

احرص على أمان SECRET_KEY

عدّل إعدادات CORS و ALLOWED_HOSTS حسب البيئة

💡 الخلاصة:
هذا الدليل يعطيك صورة كاملة عن هيكل المشروع، التقنيات المستخدمة، كيفية التعامل مع الوقت الحقيقي عبر WebSocket، وكيفية تشغيل المشروع محلياً لتطوير تطبيق Flutter متصل بالـ backend.
