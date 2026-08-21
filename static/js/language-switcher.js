// Language Switcher JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Get current language from HTML lang attribute
    const currentLang = document.documentElement.lang;
    
    // Update page direction and styles based on language
    function updatePageDirection(lang) {
        const html = document.documentElement;
        const body = document.body;
        
        if (lang === 'ar') {
            html.setAttribute('dir', 'rtl');
            html.setAttribute('lang', 'ar');
            body.classList.add('rtl');
            body.classList.remove('ltr');
        } else {
            html.setAttribute('dir', 'ltr');
            html.setAttribute('lang', 'en');
            body.classList.add('ltr');
            body.classList.remove('rtl');
        }
    }
    
    // Initialize page direction
    updatePageDirection(currentLang);
    
    // Handle language switch forms
    const languageForms = document.querySelectorAll('form[action*="set_language"]');
    languageForms.forEach(form => {
        form.addEventListener('submit', function(e) {
            // Show loading indicator
            const button = form.querySelector('button[type="submit"]');
            if (button) {
                button.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Loading...';
                button.disabled = true;
            }
        });
    });
    
    // Smooth transitions for language changes
    function addTransitionClass() {
        document.body.classList.add('language-transition');
        setTimeout(() => {
            document.body.classList.remove('language-transition');
        }, 300);
    }
    
    // Add transition class when language is being changed
    const languageButtons = document.querySelectorAll('.language-switcher button');
    languageButtons.forEach(button => {
        button.addEventListener('click', addTransitionClass);
    });
    
    // Update Bootstrap components for RTL
    function updateBootstrapRTL() {
        if (currentLang === 'ar') {
            // Update dropdown positions
            const dropdowns = document.querySelectorAll('.dropdown-menu');
            dropdowns.forEach(dropdown => {
                dropdown.classList.add('dropdown-menu-end');
            });
            
            // Update modal positions
            const modals = document.querySelectorAll('.modal');
            modals.forEach(modal => {
                modal.classList.add('modal-rtl');
            });
        }
    }
    
    updateBootstrapRTL();
    
    // Handle form validation messages in both languages
    const validationMessages = {
        'ar': {
            'required': 'هذا الحقل مطلوب',
            'email': 'يرجى إدخال بريد إلكتروني صحيح',
            'minlength': 'يجب أن يكون النص أطول',
            'maxlength': 'يجب أن يكون النص أقصر'
        },
        'en': {
            'required': 'This field is required',
            'email': 'Please enter a valid email',
            'minlength': 'Text should be longer',
            'maxlength': 'Text should be shorter'
        }
    };
    
    // Update form validation messages
    function updateValidationMessages() {
        const forms = document.querySelectorAll('form');
        forms.forEach(form => {
            const inputs = form.querySelectorAll('input, textarea, select');
            inputs.forEach(input => {
                if (input.hasAttribute('required')) {
                    input.setAttribute('title', validationMessages[currentLang]['required']);
                }
            });
        });
    }
    
    updateValidationMessages();
    
    // Handle number formatting based on language
    function formatNumbers() {
        const numbers = document.querySelectorAll('.number-format');
        numbers.forEach(element => {
            const number = parseFloat(element.textContent);
            if (!isNaN(number)) {
                if (currentLang === 'ar') {
                    element.textContent = number.toLocaleString('ar-SA');
                } else {
                    element.textContent = number.toLocaleString('en-US');
                }
            }
        });
    }
    
    formatNumbers();
    
    // Handle date formatting based on language
    function formatDates() {
        const dates = document.querySelectorAll('.date-format');
        dates.forEach(element => {
            const dateStr = element.getAttribute('data-date');
            if (dateStr) {
                const date = new Date(dateStr);
                if (currentLang === 'ar') {
                    element.textContent = date.toLocaleDateString('ar-SA');
                } else {
                    element.textContent = date.toLocaleDateString('en-US');
                }
            }
        });
    }
    
    formatDates();
    
    // Add keyboard shortcuts for language switching
    document.addEventListener('keydown', function(e) {
        // Ctrl + Shift + L to toggle language
        if (e.ctrlKey && e.shiftKey && e.key === 'L') {
            e.preventDefault();
            const currentLang = document.documentElement.lang;
            const newLang = currentLang === 'ar' ? 'en' : 'ar';
            
            // Find and submit the appropriate language form
            const targetForm = document.querySelector(`form input[name="language"][value="${newLang}"]`);
            if (targetForm) {
                targetForm.closest('form').submit();
            }
        }
    });
    
    // Save language preference in localStorage
    function saveLanguagePreference(lang) {
        localStorage.setItem('preferred_language', lang);
    }
    
    // Load language preference from localStorage
    function loadLanguagePreference() {
        return localStorage.getItem('preferred_language');
    }
    
    // Auto-switch to preferred language if different from current
    const preferredLang = loadLanguagePreference();
    if (preferredLang && preferredLang !== currentLang) {
        const targetForm = document.querySelector(`form input[name="language"][value="${preferredLang}"]`);
        if (targetForm) {
            // Auto-switch after a short delay
            setTimeout(() => {
                targetForm.closest('form').submit();
            }, 1000);
        }
    }
    
    // Save current language as preference
    saveLanguagePreference(currentLang);
});