# تقرير شامل لمجلد المشروع (medical_platform)

يوضح هذا التقرير بنية المجلد c:\Users\asus\Desktop\ge والملفات داخله مع نبذة موجزة عن وظيفة كل ملف/صفحة. يغطي الباكند (Django) والواجهات (Flutter) وصفحات القوالب (HTML) والملفات الثابتة (JS/CSS) والسكربتات.

## نظرة عامة

- **Back-end (Django 5 + DRF + Channels + SimpleJWT)**: تطبيقات accounts, patients, doctors, payments, admin_panel, core.
- **Front-end (Flutter - doctor_app)**: شاشات المريض، خدمات REST/WS، وعناصر الواجهة.
- **Realtime**: WebSocket عبر Channels، وميدلوير JWT لربط الجلسات.

---

## 1) جذر المشروع (Root)

- **manage.py**: نقطة تشغيل أوامر Django (migrate, runserver...)
- **api_urls.py**: تجميع/توجيه روابط API العلوية (إن وُجدت إشارات لتجميع مسارات التطبيقات).
- **requirements.txt**: متطلبات Python.
- **db.sqlite3**: قاعدة بيانات التطوير.
- **run.bat / run_app.bat / setup.bat / restart_flutter_app.bat**: سكربتات مساعدة لتشغيل الخادم/التطبيق.
- **assign_cases_to_doctor.py / create_patient_user.py / force_logout.py / clear_app_data.py / clear_flutter_data.py / debug_flutter_app.py / debug_flutter_step_by_step.py / mark_all_doctor_notifications_read.py**: سكربتات إدارية/تشغيلية لأتمتة مهام شائعة.

---

## 2) إعدادات وإطار Django (medical_platform)

- **medical_platform/settings.py**: الإعدادات الرئيسية للمشروع (INSTALLED_APPS, DATABASE, AUTH, CHANNELS...).
- **medical_platform/settings_production.py**: إعدادات الإنتاج (تحسينات الأمان، Redis لقنوات، إلخ).
- **medical_platform/urls.py**: مسارات Django العامة وتجميع مسارات التطبيقات.
- **medical_platform/asgi.py**: نقطة تشغيل ASGI لقنوات الويب السريعة والتعامل مع WebSocket.
- **medical_platform/wsgi.py**: نقطة تشغيل WSGI للتوافق التقليدي (HTTP فقط).
- **medical_platform/jwt_channels_middleware.py**: ميدلوير مصادقة JWT لربط المستخدمين عبر WebSocket.

---

## 3) تطبيق الحسابات (accounts)

- **models.py**: تعريف نموذج المستخدم المخصص CustomUser وحقوله الإضافية.
- **serializers.py**: محولات DRF لتحويل بيانات المستخدم/الجلسات.
- **views.py / api_views.py**: واجهات دخول/تسجيل/تحديث الملف الشخصي، نقاط API.
- **urls.py**: مسارات الواجهات الكلاسيكية.
- **backends.py / authentication.py**: لوجيك المصادقة المخصص، دعم JWT.
- **forms.py / login_forms.py**: نماذج إدخال Django للاستمارات.
- **validators.py**: تحقق من صحة الحقول (كلمات مرور، بريد...)
- **admin.py**: تسجيل النماذج في لوحة إدارة Django.
- **context_processors.py**: سياقات عامة للقوالب.
- **migrations/**: ترحيلات قاعدة البيانات.
- **tests.py**: اختبارات وحدات/تكامل للحسابات.

---

## 4) تطبيق المرضى (patients)

- **models.py**: نماذج الحالة الطبية MedicalCase، ردود الأطباء DoctorResponse، المرفقات ResponseAttachment، الإشعارات PatientNotification، التقييمات DoctorRating.
- **api_views.py / api_urls.py**: نقاط API لإنشاء الحالة، الاستعلام، التنبيهات، الترجمة المساعدة…
- **views.py / urls.py**: صفحات ويب (إن وجدت) لمسارات المرضى.
- **signals.py**: إشارات تُطلق أحداث (مثل إنشاء إشعار/بث WS عند تغيّر النماذج).
- **routing.py**: تعريف مسارات قنوات WebSocket (مجموعة per-user مثل user\_{id}).
- **ws_consumers.py**: مستهلكو Channels لبث التحديثات الفورية للواجهة.
- **forms.py**: نماذج إدخال Django للحالات.
- **migrations/**: ترحيلات قاعدة البيانات للحالات/الردود/الإشعارات...
- **tests.py**: اختبارات وظائف المرضى.

---

## 5) تطبيق الأطباء (doctors)

- **models.py**: نموذج الطبيب وحقول الملف الشخصي والحالة والتقييم.
- **serializers.py**: محولات DRF لبيانات الطبيب.
- **api_views.py / api_urls.py**: API لقائمة الأطباء، توفّرهم، الإشعارات...
- **views.py / urls.py**: صفحات ويب (إن وُجدت) لإدارة/عرض معلومات الأطباء.
- **signals.py**: إشعارات للأطباء عند الأحداث (مثل حجز/حالة جديدة).
- **forms.py**: نماذج إدارة/تحديث بيانات الطبيب.
- **admin.py**: تكوين لوحة الإدارة للأطباء.
- **migrations/**: ترحيلات قاعدة البيانات.
- **tests.py**: اختبارات وظائف الأطباء.

---

## 6) تطبيق المدفوعات (payments)

- **models.py**: نماذج الدفع (العمليات، طرق الدفع، الاشتراكات...).
- **payment_service.py**: منطق الأعمال للمدفوعات (رسوم الاستشارة، الاشتراكات، سحب الأرباح).
- **views.py / urls.py**: صفحات/نقاط دفع، تاريخ المدفوعات، طرق الدفع.
- **forms.py**: نماذج Django لطرق الدفع وطلبات السحب.
- **admin.py**: إدارة نماذج الدفع في لوحة الإدارة.
- **migrations/**: ترحيلات قاعدة البيانات.

---

## 7) لوحة الإدارة الموسعة (admin_panel)

- **views/doctor_management_views.py**: واجهات إدارة الأطباء (اعتماد/رفض، تحديث البيانات).
- **api_views.py / api_urls.py**: واجهات API لإدارة المستخدمين/الأطباء/الحالات.
- **models.py**: نماذج إشعارات/إعدادات إدارية (إن وُجدت).
- **urls.py**: مسارات لوحة الإدارة.
- **admin.py**: تخصيصات لوحة إدارة Django.
- **context_processors.py**: بيانات إضافية للقوالب.
- **migrations/**: ترحيلات.
- **tests.py**: اختبارات.

---

## 8) تطبيق النواة (core)

- **models.py**: نماذج أساسية مثل ContactMessage و FAQ.
- **views.py**: صفحات رئيسية (home, about, contact, faq) ومعالجة تغيير اللغة.
- **urls.py**: المسارات العامة + مسار ترجمة JSON تحت `utils/translate/`.
- **translation_service.py**: خدمة ترجمة متقدمة (Google Translate + قاموس طبي + كاش + كشف لغة).
- **language_views.py**: مساعدة للغات/التبديل (إن وُجدت وظائف إضافية).
- **admin.py / apps.py**: تعريف التطبيق وإعدادات الإدارة.
- **migrations/**: ترحيلات.
- **tests.py**: اختبارات.

---

## 9) قوالب الويب (templates)

- مجلدات فرعية لكل تطبيق:
  - **templates/accounts/**: صفحات دخول/تسجيل/الملف الشخصي/الجلسات وتغيير كلمة المرور.
  - **templates/patients/**: صفحات حالات المريض (لوحة التحكم، حالة جديدة، تفاصيل، اختيار طبيب، الإشعارات، الدفع…)
  - **templates/doctors/**: صفحات الطبيب (لوحة التحكم، الحالات، الردود، التقييمات، الإشعارات…)
  - **templates/admin_panel/**: إدارة المستخدمين/الأطباء/الحالات/التنبيهات/الإحصاءات.
  - **templates/payments/**: صفحات الدفع (طرق الدفع، عملية الدفع، نجاح/إلغاء، اشتراك الطبيب، أرباح الطبيب، السحب، تاريخ المدفوعات).
  - **templates/core/**: الصفحات العامة (home, home_enhanced, home_slides, about, contact, faq).
  - أمثلة ملفات بارزة (حسب الفهرسة):
    - payments: `payment.html`, `consultation_payment.html`, `payment_methods.html`, `payment_history.html`, `payment_success.html`, `cancel.html`, `doctor_subscription.html`, `doctor_earnings.html`, `withdrawal_request.html`, `success.html`.
    - admin_panel: `dashboard.html`, `manage_users.html`, `manage_doctors.html`, `manage_cases.html`, `notifications.html`, `responses.html`, `response_detail.html`, `statistics.html`, `send_notification.html`, `update_user.html`, `update_doctor.html`, `update_case.html`, `base.html`.
    - patients: `dashboard.html`, `new_case.html`, `all_cases.html`, `case_detail.html`, `confirm_case.html`, `select_doctor.html`, `select_doctor_payment.html`, `my_responses.html`, `notifications.html`, `payment.html`, `rate_doctor.html`.
    - doctors: `dashboard.html`, `all_patient_cases.html`, `case_detail.html`, `my_responses.html`, `notifications.html`, `pending.html`, `respond_case.html`, `send_notification.html`, `register.html`, `my_ratings.html`.
    - accounts: `login.html`, `register.html`, `doctor_register.html`, `enhanced_doctor_register.html`, `profile.html`, `sessions.html`, `change_password.html`, `deactivate.html`, `delete_account.html`.
    - core: `home.html`, `home_enhanced.html`, `home_slides.html`, `about.html`, `contact.html`, `faq.html`.

> ملاحظة: كل صفحة HTML تقدم واجهة العرض المقابلة لوظائف التطبيق (عرض قوائم/تفاصيل، نماذج إدخال، تأكيدات، جداول إحصائية…)

---

## 10) الملفات الثابتة (static)

- **static/js/**
  - `language-switcher.js` و`enhanced-language-switcher.js` و`simple-language-switcher.js`: التبديل بين اللغات في الواجهة.
  - `instant-translator.js`: مساعد ترجمة فوري داخل الويب.
  - `arabic-support.js`: تحسينات دعم العربية.
  - `medical-platform.js` / `admin-panel.js`: وظائف عامة للمنصة ولوحة الإدارة.
- **static/css/**
  - `style.css` + حزمة تحسينات (`design-system.css`, `components.css`, `global-enhancements.css`).
  - صفحات مخصصة: `patient-dashboard.css`, `doctor-dashboard.css`, `admin-dashboard.css`.
  - دعم لغات وألوان: `multilingual.css`, `language-switcher.css`, `enhanced-colors.css`, `modern-colors.css`.
  - عناصر Premium: `premium-navbar.css`, `premium-footer.css`, `premium-typography.css`.
  - `translation-enhanced.css`: تنسيق خاص بعرض/صندوق الترجمة.
- **staticfiles/**: نُسخ مجمّعة/مجمّدة من الملفات الثابتة للاستخدام الإنتاجي.

---

## 11) تطبيق Flutter (doctor_app)

- **lib/services/**
  - `base_api_service.dart`: اتصال HTTP أساسي، إدارة الاستجابة/الأخطاء.
  - `api_service.dart`: نقاط REST عالية المستوى (الأطباء، الحالات، إلخ).
  - `auth_api_service.dart`: مصادقة وتوكين JWT.
  - `patient_api_service.dart`: خدمات خاصة بالمريض (رفع مرفقات الحالة مثلاً).
  - `translation_service.dart`: استدعاء API للترجمة (`/utils/translate/`) مع fallback.
- **lib/screens/patient/**
  - cases/
    - `create_case_screen.dart`: إنشاء حالة جديدة للمريض، اختيار طبيب، رفع ملفات، ترجمة فورية بنمط Google، الانتقال للدفع.
  - doctors/
    - `doctor_list_screen.dart`: عرض قائمة الأطباء مع التصفية والتفاصيل والنوافذ المنبثقة والحجز.
  - payment/
    - `payment_screen.dart`: تنفيذ/محاكاة الدفع؛ بعد النجاح يتم إنشاء الحالة (إن لم تكن موجودة) ورفع المرفقات ثم الرجوع للوحة التحكم.
  - dashboard/
    - قد تشمل شاشات كـ `professional_patient_dashboard.dart`: لوحة تحكم المريض (قائمة الحالات، الإشعارات...).
- **lib/widgets/**
  - `custom_button.dart`, `custom_text_field.dart`, `custom_app_bar.dart`, `custom_bottom_nav.dart`: عناصر واجهة مخصصة قابلة لإعادة الاستخدام.
  - `case_card.dart`, `stats_card.dart`, `enhanced_card.dart`, `enhanced_buttons.dart`, `enhanced_inputs.dart`, `file_viewer.dart`, `home_widgets.dart`, `language_switcher.dart`.
- **lib/utils/**
  - `app_theme.dart`: ألوان وخطوط وتنسيقات عامة للتطبيق.
  - `constants.dart`, `helpers.dart`, `validators.dart`, `responsive_helper.dart`: ثوابت وأدوات مساعدة والتحقق من المدخلات.

> ملاحظة: قد توجد ملفات إضافية في doctor_app (main.dart ومسارات أخرى) لم تُظهرها نتائج الفهرسة المختصرة.

---

## 12) الاختبارات والوثائق

- **test_server_status.py**: اختبار حالة الخادم.
- **test_patient_login.py**: اختبار تسجيل دخول المريض.
- **.zencoder/rules/repo.md**: وصف سريع لمكونات المشروع وإعداد التشغيل المحلي.

---

## ملاحظات عامة

- القنوات (Channels) مفعلة مع InMemoryChannelLayer للتطوير، ويوصى بـ Redis في الإنتاج.
- تكامل Flutter يعتمد على JWT في REST وQuery Param للـ WebSocket.
- الترجمة في الباكند تدعم قاموسًا طبيًا + Google Translate + كاش.

إذا رغبت بتقرير أكثر تفصيلاً مع قراءة تلقائية لعناوين/Docstrings داخل كل ملف لإخراج وصف أدق، أخبرني لأقوم بتوسيعه.
