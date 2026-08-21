// Simple Language Switcher - حل بسيط لتبديل اللغة
document.addEventListener('DOMContentLoaded', function() {
    
    // قاموس الترجمات الشامل
    const translations = {
        'ar': {
            // Navigation & Basic
            'Medical Platform': 'المنصة الطبية',
            'Home': 'الرئيسية',
            'Login': 'تسجيل الدخول',
            'Register': 'إنشاء حساب',
            'Welcome': 'مرحباً بك',
            'Patient Dashboard': 'لوحة المريض',
            'Doctor Dashboard': 'لوحة الطبيب',
            'Admin Panel': 'لوحة الإدارة',
            'Profile': 'الملف الشخصي',
            'Logout': 'تسجيل الخروج',
            'Today': 'اليوم',
            'All Rights Reserved': 'جميع الحقوق محفوظة',
            'English': 'English',
            'العربية': 'العربية',
            
            // Home Page
            'Your platform to connect with international doctors without travel': 'منصتك للتواصل مع أطباء عالميين بدون سفر',
            'Create Patient Account': 'إنشاء حساب كمريض',
            'Join as Doctor': 'انضم كطبيب',
            'Dashboard': 'لوحة التحكم',
            'Send New Case': 'إرسال حالة جديدة',
            'Doctor Panel': 'لوحة الطبيب',
            
            // Patient Dashboard
            'Patient Control Panel': 'لوحة تحكم المريض',
            'Welcome back': 'مرحباً بك',
            'Total Cases': 'إجمالي الحالات',
            'Pending Cases': 'الحالات المعلقة',
            'Completed Cases': 'الحالات المكتملة',
            'New Notifications': 'الإشعارات الجديدة',
            'Quick Actions': 'الإجراءات السريعة',
            'Create New Case': 'إنشاء حالة جديدة',
            'View My Cases': 'عرض حالاتي',
            'My Responses': 'ردودي',
            'Notifications': 'الإشعارات',
            'Recent Notifications': 'الإشعارات الحديثة',
            'My Medical Cases': 'حالاتي الطبية',
            'View All': 'عرض الكل',
            'No notifications': 'لا توجد إشعارات',
            'No cases found': 'لا توجد حالات',
            'Registered Patient': 'مريض مسجل',
            'We are here to help you get the best medical care from specialized doctors': 'نحن هنا لمساعدتك في الحصول على أفضل رعاية طبية من أطباء متخصصين',
            
            // Doctor Dashboard
            'Doctor Panel': 'لوحة الطبيب',
            'Welcome Dr.': 'مرحباً بك د.',
            'Here are the medical cases that need review': 'إليك الحالات الطبية المطلوب مراجعتها',
            'Under Review': 'قيد المراجعة',
            'Responded': 'تم الرد عليها',
            'Rating': 'التقييم',
            'Review': 'تقييم',
            'Reviews': 'تقييمات',
            
            // Profile Page
            'Personal Profile': 'الملف الشخصي',
            'Update Profile': 'تحديث الملف الشخصي',
            'First Name': 'الاسم الأول',
            'Last Name': 'الاسم الأخير',
            'Email': 'البريد الإلكتروني',
            'Phone Number': 'رقم الهاتف',
            'Profile Picture': 'الصورة الشخصية',
            'Save Changes': 'حفظ التغييرات',
            'Cancel': 'إلغاء',
            'Account Information': 'معلومات الحساب',
            'Account Status': 'حالة الحساب',
            'Active': 'نشط',
            'Inactive': 'معطل',
            'Last Login': 'آخر دخول',
            'Never logged in': 'لم يسجل دخول من قبل',
            'Doctor Status': 'حالة الطبيب',
            'Pending': 'قيد المراجعة',
            'Approved': 'معتمد',
            'Rejected': 'مرفوض',
            'Specialization': 'التخصص',
            'Number of Cases': 'عدد الحالات',
            'Patient': 'مريض',
            'Doctor': 'طبيب',
            'Admin': 'مشرف',
            'Username': 'اسم المستخدم',
            'Registration Date': 'تاريخ التسجيل',
            'Not specified': 'غير محدد',
            'Choose profile picture (optional)': 'اختر صورة شخصية (اختياري)',
            
            // Common Actions
            'View': 'عرض',
            'Edit': 'تعديل',
            'Delete': 'حذف',
            'Save': 'حفظ',
            'Submit': 'إرسال',
            'Back': 'رجوع',
            'Next': 'التالي',
            'Previous': 'السابق',
            'Search': 'بحث',
            'Filter': 'تصفية',
            'Sort': 'ترتيب',
            'Export': 'تصدير',
            'Import': 'استيراد',
            'Print': 'طباعة',
            'Download': 'تحميل',
            'Upload': 'رفع',
            'Close': 'إغلاق',
            'Open': 'فتح',
            'Show': 'إظهار',
            'Hide': 'إخفاء',
            'More': 'المزيد',
            'Less': 'أقل',
            'All': 'الكل',
            'None': 'لا شيء',
            'Yes': 'نعم',
            'No': 'لا',
            'OK': 'موافق',
            'Confirm': 'تأكيد',
            'Warning': 'تحذير',
            'Error': 'خطأ',
            'Success': 'نجح',
            'Info': 'معلومات',
            'Loading': 'جاري التحميل',
            'Please wait': 'يرجى الانتظار',
            
            // Specific page translations
            'Medical Platform - Your platform to connect with international doctors': 'المنصة الطبية - منصتك للتواصل مع أطباء عالميين',
            'Your platform to connect with international doctors without travel': 'منصتك للتواصل مع أطباء عالميين بدون سفر',
            'Create Patient Account': 'إنشاء حساب كمريض',
            'Join as Doctor': 'انضم كطبيب',
            'Control Panel': 'لوحة التحكم',
            'Send New Case': 'إرسال حالة جديدة',
            'We are here to help you get the best medical care from specialized doctors': 'نحن هنا لمساعدتك في الحصول على أفضل رعاية طبية من أطباء متخصصين',
            'Here are the medical cases that need review': 'إليك الحالات الطبية المطلوب مراجعتها',
            'Under Review': 'قيد المراجعة',
            'Responded': 'تم الرد عليها',
            'Registered Patient': 'مريض مسجل',
            'Update Personal Profile': 'تحديث الملف الشخصي',
            'Personal Information': 'المعلومات الشخصية',
            'Account Settings': 'إعدادات الحساب',
            'Quick Links': 'روابط سريعة',
            'Important Links': 'روابط مهمة',
            'FAQ': 'الأسئلة الشائعة',
            'Contact Us': 'اتصل بنا',
            'Privacy Policy': 'سياسة الخصوصية'
        },
        'en': {
            'المنصة الطبية': 'Medical Platform',
            'الرئيسية': 'Home',
            'تسجيل الدخول': 'Login',
            'إنشاء حساب': 'Register',
            'مرحباً بك': 'Welcome',
            'لوحة المريض': 'Patient Dashboard',
            'لوحة الطبيب': 'Doctor Dashboard',
            'لوحة الإدارة': 'Admin Panel',
            'الملف الشخصي': 'Profile',
            'تسجيل الخروج': 'Logout',
            'اليوم': 'Today',
            'جميع الحقوق محفوظة': 'All Rights Reserved',
            'لوحة تحكم المريض': 'Patient Dashboard',
            'إجمالي الحالات': 'Total Cases',
            'الحالات المعلقة': 'Pending Cases',
            'الحالات المكتملة': 'Completed Cases',
            'الإشعارات الجديدة': 'New Notifications',
            'الإجراءات السريعة': 'Quick Actions',
            'إنشاء حالة جديدة': 'Create New Case',
            'عرض حالاتي': 'View My Cases',
            'ردودي': 'My Responses',
            'الإشعارات': 'Notifications',
            'الإشعارات الحديثة': 'Recent Notifications',
            'حالاتي الطبية': 'My Medical Cases',
            'عرض الكل': 'View All',
            'لا توجد إشعارات': 'No notifications',
            'لا توجد حالات': 'No cases found',
            'English': 'English',
            'العربية': 'العربية',
            
            // Additional reverse translations
            'المنصة الطبية - منصتك للتواصل مع أطباء عالميين': 'Medical Platform - Your platform to connect with international doctors',
            'منصتك للتواصل مع أطباء عالميين بدون سفر': 'Your platform to connect with international doctors without travel',
            'إنشاء حساب كمريض': 'Create Patient Account',
            'انضم كطبيب': 'Join as Doctor',
            'إرسال حالة جديدة': 'Send New Case',
            'نحن هنا لمساعدتك في الحصول على أفضل رعاية طبية من أطباء متخصصين': 'We are here to help you get the best medical care from specialized doctors',
            'إليك الحالات الطبية المطلوب مراجعتها': 'Here are the medical cases that need review',
            'مريض مسجل': 'Registered Patient',
            'تحديث الملف الشخصي': 'Update Personal Profile',
            'المعلومات الشخصية': 'Personal Information',
            'إعدادات الحساب': 'Account Settings',
            'روابط سريعة': 'Quick Links',
            'روابط مهمة': 'Important Links',
            'الأسئلة الشائعة': 'FAQ',
            'اتصل بنا': 'Contact Us',
            'سياسة الخصوصية': 'Privacy Policy',
            'جاري التحميل': 'Loading',
            'يرجى الانتظار': 'Please wait'
        }
    };
    
    // الحصول على اللغة الحالية
    let currentLang = localStorage.getItem('language') || 'ar';
    
    // تطبيق اللغة
    function applyLanguage(lang) {
        currentLang = lang;
        localStorage.setItem('language', lang);
        
        // تحديث اتجاه الصفحة
        const html = document.documentElement;
        const body = document.body;
        
        if (lang === 'ar') {
            html.setAttribute('dir', 'rtl');
            html.setAttribute('lang', 'ar');
            body.classList.add('rtl');
            body.classList.remove('ltr');
            
            // تحديث Bootstrap CSS
            updateBootstrapCSS('rtl');
        } else {
            html.setAttribute('dir', 'ltr');
            html.setAttribute('lang', 'en');
            body.classList.add('ltr');
            body.classList.remove('rtl');
            
            // تحديث Bootstrap CSS
            updateBootstrapCSS('ltr');
        }
        
        // ترجمة النصوص
        translateTexts(lang);
        
        // تحديث أزرار اللغة
        updateLanguageButtons(lang);
    }
    
    // تحديث Bootstrap CSS
    function updateBootstrapCSS(direction) {
        const existingLink = document.querySelector('link[href*="bootstrap"]');
        if (existingLink) {
            const newLink = document.createElement('link');
            newLink.rel = 'stylesheet';
            
            if (direction === 'rtl') {
                newLink.href = 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css';
            } else {
                newLink.href = 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css';
            }
            
            existingLink.parentNode.replaceChild(newLink, existingLink);
        }
    }
    
    // ترجمة النصوص بشكل شامل
    function translateTexts(lang) {
        // العناصر المختلفة التي تحتاج ترجمة
        const selectors = [
            '.navbar-brand', '.nav-link', '.btn', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 
            'p', 'span', '.card-title', '.section-title', '.welcome-title', '.welcome-subtitle',
            '.welcome-description', '.badge', 'label', '.form-label', '.dropdown-item',
            '.stat-label', '.doctor-stat-label', '.info-item strong', '.card-header h5',
            '.card-header h6', 'th', 'td', '.alert', '.text-muted', 'small', '.lead',
            '.hero-section h1', '.hero-section p', '.btn-custom', '[data-translate]'
        ];
        
        selectors.forEach(selector => {
            const elements = document.querySelectorAll(selector);
            elements.forEach(element => {
                translateElement(element, lang);
            });
        });
        
        // ترجمة النصوص داخل العناصر المعقدة
        translateComplexElements(lang);
    }
    
    // ترجمة عنصر واحد
    function translateElement(element, lang) {
        if (!element || !element.textContent) return;
        
        let originalText = element.textContent.trim();
        
        // إزالة الأيقونات والمسافات الإضافية
        originalText = originalText.replace(/^\s*[\u{1F300}-\u{1F9FF}]|\s*[\u{1F300}-\u{1F9FF}]\s*$/gu, '').trim();
        
        // البحث عن الترجمة
        if (translations[lang] && translations[lang][originalText]) {
            // الحفاظ على الأيقونات
            const iconMatch = element.innerHTML.match(/<i[^>]*><\/i>/);
            const icon = iconMatch ? iconMatch[0] + ' ' : '';
            
            element.innerHTML = icon + translations[lang][originalText];
        }
        
        // ترجمة جزئية للنصوص المركبة
        if (originalText.includes('،') || originalText.includes(',')) {
            let translatedText = originalText;
            Object.keys(translations[lang] || {}).forEach(key => {
                if (originalText.includes(key)) {
                    translatedText = translatedText.replace(key, translations[lang][key]);
                }
            });
            
            if (translatedText !== originalText) {
                const iconMatch = element.innerHTML.match(/<i[^>]*><\/i>/);
                const icon = iconMatch ? iconMatch[0] + ' ' : '';
                element.innerHTML = icon + translatedText;
            }
        }
    }
    
    // ترجمة العناصر المعقدة
    function translateComplexElements(lang) {
        // ترجمة النصوص في الـ placeholders
        const inputs = document.querySelectorAll('input[placeholder], textarea[placeholder]');
        inputs.forEach(input => {
            const placeholder = input.getAttribute('placeholder');
            if (translations[lang] && translations[lang][placeholder]) {
                input.setAttribute('placeholder', translations[lang][placeholder]);
            }
        });
        
        // ترجمة النصوص في الـ title attributes
        const elementsWithTitle = document.querySelectorAll('[title]');
        elementsWithTitle.forEach(element => {
            const title = element.getAttribute('title');
            if (translations[lang] && translations[lang][title]) {
                element.setAttribute('title', translations[lang][title]);
            }
        });
        
        // ترجمة النصوص في الـ alt attributes
        const images = document.querySelectorAll('img[alt]');
        images.forEach(img => {
            const alt = img.getAttribute('alt');
            if (translations[lang] && translations[lang][alt]) {
                img.setAttribute('alt', translations[lang][alt]);
            }
        });
    }
    
    // تحديث أزرار اللغة
    function updateLanguageButtons(lang) {
        const languageButtons = document.querySelectorAll('.language-btn');
        languageButtons.forEach(btn => {
            const btnLang = btn.getAttribute('data-lang');
            if (btnLang === lang) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
    }
    
    // إضافة مبدل اللغة إلى الصفحة
    function addLanguageSwitcher() {
        const navbar = document.querySelector('.navbar-nav');
        if (navbar && !document.querySelector('.language-switcher')) {
            const languageSwitcher = document.createElement('li');
            languageSwitcher.className = 'nav-item dropdown language-switcher';
            languageSwitcher.innerHTML = `
                <a class="nav-link dropdown-toggle" href="#" id="languageDropdown" role="button" data-bs-toggle="dropdown">
                    <i class="fas fa-globe me-1"></i>
                    <span class="language-text">${currentLang === 'ar' ? 'العربية' : 'English'}</span>
                </a>
                <ul class="dropdown-menu">
                    <li>
                        <button class="dropdown-item language-btn ${currentLang === 'ar' ? 'active' : ''}" data-lang="ar">
                            <i class="fas fa-flag me-2"></i>العربية
                        </button>
                    </li>
                    <li>
                        <button class="dropdown-item language-btn ${currentLang === 'en' ? 'active' : ''}" data-lang="en">
                            <i class="fas fa-flag me-2"></i>English
                        </button>
                    </li>
                </ul>
            `;
            
            navbar.appendChild(languageSwitcher);
            
            // إضافة مستمعي الأحداث
            const languageButtons = languageSwitcher.querySelectorAll('.language-btn');
            languageButtons.forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const newLang = this.getAttribute('data-lang');
                    if (newLang !== currentLang) {
                        applyLanguage(newLang);
                        
                        // تحديث نص المبدل
                        const languageText = document.querySelector('.language-text');
                        if (languageText) {
                            languageText.textContent = newLang === 'ar' ? 'العربية' : 'English';
                        }
                        
                        // إعادة تحميل الصفحة لتطبيق التغييرات بالكامل
                        setTimeout(() => {
                            window.location.reload();
                        }, 500);
                    }
                });
            });
        }
    }
    
    // تطبيق اللغة المحفوظة
    applyLanguage(currentLang);
    
    // إضافة مبدل اللغة
    addLanguageSwitcher();
    
    // إضافة CSS للتحسينات
    const style = document.createElement('style');
    style.textContent = `
        .language-switcher .dropdown-item.active {
            background-color: var(--bs-primary);
            color: white;
        }
        
        .language-transition {
            transition: all 0.3s ease;
        }
        
        .rtl .dropdown-menu {
            right: 0;
            left: auto;
        }
        
        .rtl .me-1, .rtl .me-2 {
            margin-right: 0;
            margin-left: 0.25rem;
        }
        
        .rtl .ms-1, .rtl .ms-2 {
            margin-left: 0;
            margin-right: 0.25rem;
        }
    `;
    document.head.appendChild(style);
    
    // اختصار لوحة المفاتيح لتبديل اللغة
    document.addEventListener('keydown', function(e) {
        if (e.ctrlKey && e.shiftKey && e.key === 'L') {
            e.preventDefault();
            const newLang = currentLang === 'ar' ? 'en' : 'ar';
            applyLanguage(newLang);
            
            // تحديث نص المبدل
            const languageText = document.querySelector('.language-text');
            if (languageText) {
                languageText.textContent = newLang === 'ar' ? 'العربية' : 'English';
            }
            
            setTimeout(() => {
                window.location.reload();
            }, 500);
        }
    });
    
    console.log('Simple Language Switcher loaded successfully');
});