# تقرير تفصيلي لهيكلة المشروع (medical_platform)

يوثّق هذا التقرير جميع المجلدات والملفات المهمة (صفحات الويب، ملفات Flutter، وملفات Django) ويشرح باختصار وظيفة كل ملف ودوره داخل الكود.

## دليل القراءة

- مُنظّم حسب المجلدات الرئيسية.
- تحت كل قسم، ستجد كل ملف مع وصف سطري واضح لوظيفته.
- يغطي: Django (Python)، القوالب (HTML)، الملفات الثابتة (JS/CSS)، وتطبيق Flutter (Dart).

---

## 1) الجذر Root: `c:\Users\asus\Desktop\ge`

- **manage.py**: نقطة تشغيل أوامر Django (migrate, runserver, createsuperuser...).
- **api_urls.py**: تجميع لمسارات API العلوية على مستوى المشروع (إن وُظّف لذلك).
- **requirements.txt**: قائمة تبعيات Python.
- **db.sqlite3**: قاعدة بيانات التطوير المحلية.
- **run.bat / run_app.bat / setup.bat / restart_flutter_app.bat**: سكربتات مساعدة لتشغيل الخادم والتطبيق وإعداد البيئة.
- **assign_cases_to_doctor.py**: سكربت يعين الحالات لطبيب معيّن تلقائيًا (للاختبار/الإدارة).
- **create_patient_user.py**: سكربت إنشاء مستخدم مريض تجريبي.
- **force_logout.py**: إنهاء جلسات المستخدمين (تنظيف توكن/جلسة).
- **clear_app_data.py / clear_flutter_data.py**: تنظيف بيانات التطبيق/Flutter أثناء التطوير.
- **debug_flutter_app.py / debug_flutter_step_by_step.py**: أدوات تصحيح لتطبيق Flutter.
- **mark_all_doctor_notifications_read.py**: تعليم إشعارات الأطباء كمقروءة.
- **test_server_status.py**: اختبار صحة خادم Django (استجابة/حالة).
- **test_patient_login.py**: اختبار تسجيل دخول المريض عبر API.

---

## 2) مشروع Django: `medical_platform/`

- **settings.py**: الإعدادات العامة (تطبيقات منصّبة، قواعد بيانات، AUTH، CORS، CHANNELS...).
- **settings_production.py**: تهيئة الإنتاج (أمان، Redis لقنوات، إعدادات ضغط/ستاتيك...).
- **urls.py**: توجيه مسارات Django الأساسية وتجميع مسارات التطبيقات.
- **asgi.py**: نقطة الدخول لخادم ASGI (قنوات وWebSocket).
- **wsgi.py**: نقطة الدخول لخادم WSGI (HTTP فقط).
- **jwt_channels_middleware.py**: ميدلوير مصادقة JWT لقنوات WebSocket (يربط المستخدم بالتوكن).
- ****init**.py**: تهيئة حزمة Python للمشروع.

---

## 3) تطبيق الحسابات: `accounts/`

- **models.py**: نموذج مستخدم مخصص CustomUser (نوع المستخدم، حقول إضافية...).
- **serializers.py**: محولات DRF لبيانات المستخدم والجلسات.
- **views.py**: عروض/صفحات تقليدية (تسجيل، دخول، ملف شخصي...).
- **api_views.py**: نقاط REST (تسجيل/دخول JWT، تحديث ملف، جلسات...).
- **urls.py**: مسارات واجهات الموقع للحسابات.
- **backends.py**: Backends مصادقة مخصصة (دعم طرق دخول إضافية).
- **authentication.py**: كلاس/دوال مصادقة JWT وتحقّق توكن.
- **forms.py / login_forms.py**: نماذج Django لاستمارات الحساب.
- **validators.py**: قواعد تحقق (كلمة مرور، بريد...)
- **admin.py**: تسجيل نماذج الحسابات في لوحة الإدارة.
- **context_processors.py**: سياقات عامة للقوالب مرتبطة بالمستخدم/الجلسة.
- **migrations/**: ترحيلات قاعدة البيانات الخاصة بالحسابات.
- **tests.py**: اختبارات وحدات/تكامل لوظائف الحسابات.

---

## 4) تطبيق المرضى: `patients/`

- **models.py**: نماذج MedicalCase, DoctorResponse, ResponseAttachment, PatientNotification, DoctorRating.
- **api_views.py**: REST لإنشاء الحالات، استعراضها، تحميل مرفقات، إشعارات، ترجمات مساعدة.
- **api_urls.py**: تجميع مسارات REST الخاصة بالمرضى.
- **views.py**: عروض صفحات ويب (لو وُجدت صفحات HTML للمريض).
- **urls.py**: مسارات الويب المتعلقة بواجهات المريض.
- **ws_consumers.py**: مستهلك Channels لبث التحديثات الفورية للمريض (WS per-user group).
- **routing.py**: تعريف مسار WebSocket مثل `/ws/stream/` وربطه بالمستهلك.
- **signals.py**: إطلاق إشعارات/أحداث WS عند تغيّر النماذج (إنشاء/تحديث/ردود...).
- **forms.py**: نماذج إدخال لحالة جديدة/مرفقات.
- **migrations/**: ترحيلات قاعدة البيانات لكافة نماذج المرضى.
- **tests.py**: اختبارات وظائف المرضى.
- ****init**.py / apps.py**: تهيئة التطبيق.

---

## 5) تطبيق الأطباء: `doctors/`

- **models.py**: نموذج الطبيب (بيانات، حالة اعتماد، تقييم، تفضيلات، عملة...).
- **serializers.py**: تحويل بيانات الطبيب لواجهات REST.
- **api_views.py**: REST لقائمة الأطباء، توفرهم، إشعاراتهم.
- **api_urls.py**: مسارات REST للأطباء.
- **views.py**: صفحات ويب للأطباء (إن وُجدت).
- **urls.py**: مسارات الويب لعرض/إدارة معلومات الأطباء.
- **signals.py**: إطلاق إشعارات عند أحداث (حجز/حالة جديدة).
- **forms.py**: نماذج إدارة بيانات الطبيب وتحديثها.
- **admin.py**: تخصيص لوحة الإدارة لعرض نماذج الأطباء.
- **migrations/**: ترحيلات نماذج الطبيب.
- **tests.py**: اختبارات.

---

## 6) تطبيق المدفوعات: `payments/`

- **models.py**: نماذج الدفع (Transactions, PaymentMethod, Subscriptions...).
- **payment_service.py**: منطق رسوم الاستشارة، الاشتراكات، سحب أرباح الطبيب.
- **views.py**: عروض/صفحات دفع (طرق الدفع، الدفع، السجل...)
- **urls.py**: مسارات الدفع.
- **forms.py**: نماذج Django لطرق الدفع وطلبات السحب.
- **admin.py**: إدارة نماذج الدفع عبر لوحة الإدارة.
- **migrations/**: ترحيلات نماذج الدفع.

---

## 7) لوحة الإدارة: `admin_panel/`

- **views/doctor_management_views.py**: إدارة الأطباء (اعتماد/رفض، تعديل بيانات، عرض تفاصيل).
- **api_views.py**: REST لإدارة المستخدمين/الأطباء/الحالات والإحصاءات.
- **api_urls.py**: مسارات REST للوحة الإدارة.
- **models.py**: نماذج إعدادات/إشعارات إدارية (إن وُجدت).
- **urls.py**: مسارات صفحات لوحة الإدارة.
- **admin.py**: تخصيصات لوحة إدارة Django لعناصر اللوحة.
- **context_processors.py**: سياقات مساعدة لقوالب اللوحة.
- **migrations/**: ترحيلات.
- **tests.py**: اختبارات.

---

## 8) النواة Core: `core/`

- **models.py**: ContactMessage, FAQ ونماذج عامة.
- **views.py**: صفحات رئيسية (home/about/contact/faq) + `set_language` لتبديل اللغة + API توجيه قديم.
- **urls.py**: مسارات عامة + **`utils/translate/`** لخدمة الترجمة JSON للموبايل.
- **translation_service.py**: محرك ترجمة متقدم (كشف لغة مُحسّن + Google Translate + قاموس طبي + كاش).
- **language_views.py**: وظائف مساعدة للغات والتبديل (إن لزم).
- **admin.py / apps.py**: تهيئة وإدارة التطبيق.
- **migrations/**: ترحيلات.
- **tests.py**: اختبارات أساسية.

---

## 9) قوالب الويب Templates: `templates/`

### accounts/

- **login.html**: صفحة تسجيل الدخول للمستخدم.
- **register.html**: صفحة إنشاء حساب جديد للمريض/المستخدم.
- **doctor_register.html**: تسجيل طبيب مع حقول مهنية.
- **enhanced_doctor_register.html**: نسخة محسّنة لتسجيل الطبيب.
- **profile.html**: عرض/تعديل الملف الشخصي.
- **sessions.html**: جلسات المستخدم النشطة/الإدارة.
- **change_password.html**: تغيير كلمة المرور.
- **deactivate.html**: تعطيل الحساب.
- **delete_account.html**: حذف الحساب.

### patients/

- **dashboard.html**: لوحة تحكم المريض (قائمة الحالات، الإشعارات...)
- **new_case.html**: إنشاء حالة جديدة (نموذج إدخال).
- **all_cases.html**: استعراض جميع حالات المريض.
- **case_detail.html**: تفاصيل حالة محددة.
- **confirm_case.html**: تأكيد إرسال الحالة.
- **select_doctor.html**: اختيار طبيب للحالة.
- **select_doctor_payment.html**: اختيار الطبيب مع الانتقال للدفع.
- **my_responses.html**: ردود الأطباء على حالات المريض.
- **notifications.html**: إشعارات المريض.
- **payment.html**: شاشة دفع مرتبطة بالحالة.
- **rate_doctor.html**: تقييم الطبيب بعد الاستشارة.

### doctors/

- **dashboard.html**: لوحة تحكم الطبيب (قائمة الحالات والمهام).
- **all_patient_cases.html**: جميع حالات المرضى المتاحة/الموكلة.
- **case_detail.html**: تفاصيل الحالة للطبيب (الرد/الخطة).
- **my_responses.html**: ردود الطبيب السابقة.
- **notifications.html**: إشعارات الطبيب.
- **pending.html**: حالات قيد الانتظار.
- **respond_case.html**: إرسال الرد الطبي.
- **send_notification.html**: إرسال إشعار للمريض.
- **register.html**: واجهة تسجيل الطبيب.
- **my_ratings.html**: تقييمات المرضى للطبيب.

### admin_panel/

- **base.html**: قالب رئيسي للوحة.
- **dashboard.html**: مؤشرات وإحصاءات عامة.
- **manage_users.html**: إدارة المستخدمين.
- **manage_doctors.html**: إدارة الأطباء (اعتماد/رفض/تعديل).
- **manage_cases.html**: إدارة الحالات الطبية.
- **notifications.html**: إشعارات إدارية.
- **responses.html / response_detail.html**: إدارة الردود الطبية.
- **statistics.html**: إحصاءات متقدمة.
- **send_notification.html**: إرسال التنبيهات.
- **update_user.html / update_doctor.html / update_case.html**: نماذج تحديث البيانات.

### payments/

- **payment.html**: صفحة عملية الدفع.
- **consultation_payment.html**: دفع استشارة.
- **payment_methods.html**: إدارة/عرض طرق الدفع.
- **payment_history.html**: تاريخ المدفوعات.
- **payment_success.html / cancel.html**: نتائج الدفع (نجاح/إلغاء).
- **doctor_subscription.html**: اشتراك الطبيب.
- **doctor_earnings.html**: أرباح الطبيب وسحب الرصيد.
- **withdrawal_request.html**: طلب سحب أرباح.
- **success.html**: صفحة نجاح عامة.

### core/

- **home.html / home_enhanced.html / home_slides.html**: صفحات رئيسية بأشكال عرض مختلفة.
- **about.html**: من نحن.
- **contact.html**: تواصل معنا (نموذج إرسال رسالة).
- **faq.html**: الأسئلة الشائعة.

---

## 10) ملفات JavaScript: `static/js/`

- **language-switcher.js / enhanced-language-switcher.js / simple-language-switcher.js**: تبديل اللغة في الواجهة (أساسي/محسّن/مبسّط).
- **instant-translator.js**: أداة ترجمة فورية داخل صفحات الويب.
- **arabic-support.js**: تحسينات دعم العربية والاتجاه.
- **medical-platform.js**: وظائف عامة للمنصة (تفاعلات/مكونات).
- **admin-panel.js**: وظائف خاصة بلوحة الإدارة (جدولة/تصفية/تفاعلات).

## 11) ملفات CSS: `static/css/`

- **style.css**: النمط العام للموقع.
- **design-system.css / components.css**: نظام تصميم ومكوّنات جاهزة.
- **global-enhancements.css**: تحسينات عامة للمظهر.
- **patient-dashboard.css / doctor-dashboard.css / admin-dashboard.css**: تخصيص واجهات لوحات المستخدمين.
- **multilingual.css / language-switcher.css**: دعم متعدد اللغات وتبديلها.
- **enhanced-colors.css / modern-colors.css**: لوحات ألوان محسّنة وحديثة.
- **premium-navbar.css / premium-footer.css / premium-typography.css**: عناصر واجهة بريميوم.
- **translation-enhanced.css**: تنسيق خاص لصندوق الترجمة.

> ملاحظة: `staticfiles/` يحتوي نسخًا مجمّعة وجاهزة للإنتاج من JS/CSS.

---

## 12) تطبيق Flutter: `doctor_app/`

### الخدمات `lib/services/`

- **base_api_service.dart**: عميل HTTP أساسي (رؤوس/أخطاء/تحليل الاستجابة).
- **api_service.dart**: واجهة REST عالية المستوى (أطباء، حالات، رفع مرفقات...).
- **auth_api_service.dart**: مصادقة المستخدمين وJWT.
- **patient_api_service.dart**: وظائف تخص المريض (رفع مرفقات الحالة...).
- **translation_service.dart**: طلب ترجمة عبر `/core/utils/translate/` مع تعامل مع النتائج.

### الشاشات `lib/screens/patient/`

- cases/
  - **create_case_screen.dart**: إنشاء حالة جديدة، اختيار طبيب، مرفقات، مترجم فوري بنمط Google، انتقال للدفع.
- doctors/
  - **doctor_list_screen.dart**: قائمة الأطباء بتفاصيل/تقييمات وبطاقة ملف شخصي منبثقة وحجز.
- payment/
  - **payment_screen.dart**: تنفيذ/محاكاة الدفع؛ في حال لا يوجد `caseId` يقوم بإنشاء الحالة ورفع المرفقات ثم العودة للوحة.

> قد توجد شاشات إضافية (dashboard/...) حسب تقدم التطوير.

### الودجات `lib/widgets/`

- **custom_button.dart / custom_text_field.dart / custom_app_bar.dart / custom_bottom_nav.dart**: عناصر قابلة لإعادة الاستخدام.
- **case_card.dart**: بطاقة عرض حالة طبية مختصرة.
- **stats_card.dart**: بطاقات إحصائية.
- **enhanced_card.dart / enhanced_buttons.dart / enhanced_inputs.dart**: عناصر محسّنة للتجربة البصرية.
- **file_viewer.dart**: عرض ملفات/صور مرفقة.
- **home_widgets.dart**: ودجات للصفحة الرئيسية/لوحات.
- **language_switcher.dart**: مبدّل لغة داخل التطبيق.

### الأدوات `lib/utils/`

- **app_theme.dart**: ثيم/ألوان وخطوط عامة للتطبيق.
- **constants.dart**: ثوابت عامة (روابط، مفاتيح...).
- **helpers.dart**: دوال مساعدة شائعة.
- **validators.dart**: مدققات إدخال.
- **responsive_helper.dart**: أدوات استجابة للشاشات.

---

## 13) وسائط وإخراج

- **media/**: ملفات رفع مثل مرفقات الحالات، ردود الأطباء (PDF/صور/فيديوهات)، رخص الأطباء، صور ملفات شخصية.

---

## 14) كيف ترتبط الأجزاء ببعضها

- عند إنشاء حالة من Flutter:
  1. يتم الدفع عبر `payment_screen.dart`.
  2. بعد النجاح: إذا لا يوجد `caseId`، تُنشأ الحالة عبر `api_service.dart` وتُرفع المرفقات عبر `patient_api_service.dart`.
  3. في Django، إشارات `patients/signals.py` قد تطلق إشعارات عبر Channels.
  4. واجهات الويب تعكس البيانات عبر قوالب `templates/`، وRealtime عبر WebSocket.
- الترجمة:
  - الواجهة (Flutter) تستخدم `translation_service.dart` لمكالمات `/core/utils/translate/`.
  - السيرفر ينفّذ `core/translation_service.py` (قاموس طبي + Google Translate + كاش).

---

## 15) ملاحظات ختامية

- يمكن تعميق التقرير بقراءة Docstrings/التعليقات داخل الملفات لاستخراج وصف أوضح للدوال والفئات.
- أخبرني إن رغبت بإصدار مُوسّع يشمل توقيعات الدوال ومسارات REST وقنوات WS مع أمثلة طلب/استجابة.
