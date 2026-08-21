/**
 * دعم الأسماء العربية والإنجليزية في النماذج
 */

document.addEventListener('DOMContentLoaded', function() {
    // العثور على جميع حقول اسم المستخدم
    const usernameFields = document.querySelectorAll('input[name="username"], input[id*="username"]');
    
    usernameFields.forEach(function(field) {
        // إضافة دعم التبديل التلقائي للاتجاه
        field.setAttribute('dir', 'auto');
        
        // إضافة معالج للكتابة
        field.addEventListener('input', function(e) {
            const value = e.target.value;
            
            // التحقق من وجود أحرف عربية
            const hasArabic = /[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]/.test(value);
            
            // تعديل اتجاه النص حسب المحتوى
            if (hasArabic) {
                e.target.style.direction = 'rtl';
                e.target.style.textAlign = 'right';
            } else {
                e.target.style.direction = 'ltr';
                e.target.style.textAlign = 'left';
            }
        });
        
        // إضافة تلميحات للمستخدم
        if (field.placeholder && !field.placeholder.includes('عربي')) {
            field.placeholder = field.placeholder + ' (عربي أو إنجليزي)';
        }
    });
    
    // إضافة رسائل مساعدة
    addUsernameHelp();
});

function addUsernameHelp() {
    const usernameFields = document.querySelectorAll('input[name="username"]');
    
    usernameFields.forEach(function(field) {
        // التحقق من عدم وجود رسالة مساعدة مسبقاً
        if (field.parentNode.querySelector('.username-help')) {
            return;
        }
        
        // إنشاء رسالة مساعدة
        const helpText = document.createElement('small');
        helpText.className = 'form-text text-muted username-help';
        helpText.innerHTML = `
            <i class="fas fa-info-circle me-1"></i>
            يمكنك استخدام الأحرف العربية والإنجليزية والأرقام والرموز: @/./+/-/_
        `;
        
        // إضافة الرسالة بعد الحقل
        field.parentNode.appendChild(helpText);
    });
}

// دالة للتحقق من صحة اسم المستخدم في الوقت الفعلي
function validateUsernameRealTime(field) {
    const value = field.value;
    const errorDiv = field.parentNode.querySelector('.username-error') || createErrorDiv(field);
    
    // إخفاء الأخطاء السابقة
    errorDiv.style.display = 'none';
    field.classList.remove('is-invalid');
    
    if (!value) {
        return;
    }
    
    // التحقق من الطول
    if (value.length < 3) {
        showError(field, errorDiv, 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل');
        return;
    }
    
    if (value.length > 150) {
        showError(field, errorDiv, 'اسم المستخدم يجب أن يكون 150 حرف كحد أقصى');
        return;
    }
    
    // التحقق من البداية
    if (/^[0-9@.+\-_]/.test(value)) {
        showError(field, errorDiv, 'اسم المستخدم يجب أن يبدأ بحرف عربي أو إنجليزي');
        return;
    }
    
    // التحقق من الأحرف المسموحة
    const validPattern = /^[\w\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF.@+-]+$/;
    if (!validPattern.test(value)) {
        showError(field, errorDiv, 'اسم المستخدم يحتوي على أحرف غير مسموحة');
        return;
    }
    
    // إذا وصل هنا فالاسم صحيح
    field.classList.add('is-valid');
}

function createErrorDiv(field) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'invalid-feedback username-error';
    errorDiv.style.display = 'none';
    field.parentNode.appendChild(errorDiv);
    return errorDiv;
}

function showError(field, errorDiv, message) {
    field.classList.add('is-invalid');
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
}

// إضافة التحقق في الوقت الفعلي لجميع حقول اسم المستخدم
document.addEventListener('DOMContentLoaded', function() {
    const usernameFields = document.querySelectorAll('input[name="username"]');
    
    usernameFields.forEach(function(field) {
        field.addEventListener('blur', function() {
            validateUsernameRealTime(this);
        });
        
        field.addEventListener('input', function() {
            // إزالة الأخطاء عند الكتابة
            this.classList.remove('is-invalid');
            const errorDiv = this.parentNode.querySelector('.username-error');
            if (errorDiv) {
                errorDiv.style.display = 'none';
            }
        });
    });
});