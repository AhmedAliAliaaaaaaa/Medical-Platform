/**
 * Enhanced Language Switcher for Medical Platform
 * Provides smooth language switching with animations and better UX
 */

class EnhancedLanguageSwitcher {
    constructor() {
        this.currentLanguage = document.documentElement.lang || 'ar';
        this.isRTL = this.currentLanguage === 'ar';
        this.translations = {};
        this.init();
    }

    init() {
        this.createLanguageSwitcher();
        this.loadTranslations();
        this.bindEvents();
        this.updateDirection();
        this.animateElements();
    }

    createLanguageSwitcher() {
        // Create enhanced language switcher if it doesn't exist
        if (!document.querySelector('.enhanced-language-switcher')) {
            const switcher = document.createElement('div');
            switcher.className = 'enhanced-language-switcher';
            switcher.innerHTML = `
                <div class="language-toggle">
                    <button class="lang-btn ${this.currentLanguage === 'ar' ? 'active' : ''}" data-lang="ar">
                        <span class="lang-flag">🇸🇦</span>
                        <span class="lang-text">العربية</span>
                    </button>
                    <button class="lang-btn ${this.currentLanguage === 'en' ? 'active' : ''}" data-lang="en">
                        <span class="lang-flag">🇺🇸</span>
                        <span class="lang-text">English</span>
                    </button>
                    <div class="toggle-slider"></div>
                </div>
            `;

            // Add CSS styles
            this.addStyles();

            // Insert into navbar or header
            const navbar = document.querySelector('.navbar') || document.querySelector('header') || document.body;
            navbar.appendChild(switcher);
        }
    }

    addStyles() {
        if (!document.querySelector('#enhanced-lang-styles')) {
            const styles = document.createElement('style');
            styles.id = 'enhanced-lang-styles';
            styles.textContent = `
                .enhanced-language-switcher {
                    position: fixed;
                    top: 20px;
                    right: 20px;
                    z-index: 1000;
                    background: rgba(255, 255, 255, 0.95);
                    backdrop-filter: blur(10px);
                    border-radius: 25px;
                    padding: 5px;
                    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    transition: all 0.3s ease;
                }

                .enhanced-language-switcher:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 12px 35px rgba(0, 0, 0, 0.2);
                }

                .language-toggle {
                    position: relative;
                    display: flex;
                    background: transparent;
                    border-radius: 20px;
                    overflow: hidden;
                }

                .lang-btn {
                    background: none;
                    border: none;
                    padding: 10px 15px;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    font-size: 14px;
                    font-weight: 600;
                    color: #6b7280;
                    transition: all 0.3s ease;
                    position: relative;
                    z-index: 2;
                    border-radius: 18px;
                    min-width: 100px;
                    justify-content: center;
                }

                .lang-btn:hover {
                    color: #2563eb;
                    transform: scale(1.05);
                }

                .lang-btn.active {
                    color: #ffffff;
                }

                .lang-flag {
                    font-size: 16px;
                    filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1));
                }

                .lang-text {
                    font-family: 'Cairo', sans-serif;
                }

                .toggle-slider {
                    position: absolute;
                    top: 5px;
                    left: 5px;
                    width: calc(50% - 5px);
                    height: calc(100% - 10px);
                    background: linear-gradient(135deg, #2563eb 0%, #3b82f6 100%);
                    border-radius: 15px;
                    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                    box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
                }

                .language-toggle[data-active="en"] .toggle-slider {
                    transform: translateX(100%);
                }

                /* RTL Support */
                [dir="rtl"] .enhanced-language-switcher {
                    right: auto;
                    left: 20px;
                }

                [dir="rtl"] .language-toggle[data-active="en"] .toggle-slider {
                    transform: translateX(-100%);
                }

                /* Mobile Responsive */
                @media (max-width: 768px) {
                    .enhanced-language-switcher {
                        top: 10px;
                        right: 10px;
                        transform: scale(0.9);
                    }

                    [dir="rtl"] .enhanced-language-switcher {
                        right: auto;
                        left: 10px;
                    }

                    .lang-btn {
                        min-width: 80px;
                        padding: 8px 12px;
                        font-size: 12px;
                    }

                    .lang-text {
                        display: none;
                    }
                }

                /* Animation for language switch */
                .language-switching {
                    pointer-events: none;
                }

                .fade-transition {
                    opacity: 0;
                    transform: translateY(10px);
                    transition: all 0.3s ease;
                }

                .fade-transition.active {
                    opacity: 1;
                    transform: translateY(0);
                }

                /* Loading indicator */
                .lang-loading {
                    position: relative;
                    overflow: hidden;
                }

                .lang-loading::after {
                    content: '';
                    position: absolute;
                    top: 0;
                    left: -100%;
                    width: 100%;
                    height: 100%;
                    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
                    animation: loading-shimmer 1.5s infinite;
                }

                @keyframes loading-shimmer {
                    0% { left: -100%; }
                    100% { left: 100%; }
                }
            `;
            document.head.appendChild(styles);
        }
    }

    bindEvents() {
        document.addEventListener('click', (e) => {
            if (e.target.closest('.lang-btn')) {
                const langBtn = e.target.closest('.lang-btn');
                const newLang = langBtn.dataset.lang;
                
                if (newLang !== this.currentLanguage) {
                    this.switchLanguage(newLang);
                }
            }
        });

        // Keyboard support
        document.addEventListener('keydown', (e) => {
            if (e.altKey && e.key === 'l') {
                e.preventDefault();
                const newLang = this.currentLanguage === 'ar' ? 'en' : 'ar';
                this.switchLanguage(newLang);
            }
        });
    }

    async switchLanguage(newLang) {
        if (this.isLoading) return;
        
        this.isLoading = true;
        const switcher = document.querySelector('.enhanced-language-switcher');
        const toggle = document.querySelector('.language-toggle');
        
        // Add loading state
        switcher.classList.add('lang-loading');
        document.body.classList.add('language-switching');
        
        // Update toggle slider position
        toggle.setAttribute('data-active', newLang);
        
        // Update active button
        document.querySelectorAll('.lang-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.lang === newLang);
        });

        try {
            // Add fade transition to content
            const content = document.querySelector('main') || document.body;
            content.classList.add('fade-transition');
            
            // Wait for fade out
            await this.delay(150);
            
            // Switch language via Django
            await this.switchDjangoLanguage(newLang);
            
            // Update current language
            this.currentLanguage = newLang;
            this.isRTL = newLang === 'ar';
            
            // Update direction
            this.updateDirection();
            
            // Reload page with new language
            window.location.reload();
            
        } catch (error) {
            console.error('Language switch failed:', error);
            this.showError('فشل في تغيير اللغة / Language switch failed');
        } finally {
            // Remove loading state
            switcher.classList.remove('lang-loading');
            document.body.classList.remove('language-switching');
            this.isLoading = false;
        }
    }

    async switchDjangoLanguage(newLang) {
        const formData = new FormData();
        formData.append('language', newLang);
        formData.append('csrfmiddlewaretoken', this.getCSRFToken());
        
        const response = await fetch('/i18n/setlang/', {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        });
        
        if (!response.ok) {
            throw new Error('Failed to switch language');
        }
        
        return response;
    }

    updateDirection() {
        document.documentElement.setAttribute('dir', this.isRTL ? 'rtl' : 'ltr');
        document.documentElement.setAttribute('lang', this.currentLanguage);
        
        // Update body class for styling
        document.body.classList.toggle('rtl', this.isRTL);
        document.body.classList.toggle('ltr', !this.isRTL);
        
        // Update Bootstrap RTL if available
        if (this.isRTL && !document.querySelector('link[href*="bootstrap-rtl"]')) {
            this.loadBootstrapRTL();
        }
    }

    loadBootstrapRTL() {
        const rtlLink = document.createElement('link');
        rtlLink.rel = 'stylesheet';
        rtlLink.href = 'https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.rtl.min.css';
        rtlLink.id = 'bootstrap-rtl';
        document.head.appendChild(rtlLink);
    }

    animateElements() {
        // Add entrance animations to elements
        const elements = document.querySelectorAll('.card, .btn, .form-control');
        elements.forEach((el, index) => {
            el.style.animationDelay = `${index * 0.1}s`;
            el.classList.add('fade-transition', 'active');
        });
    }

    async loadTranslations() {
        try {
            const response = await fetch(`/api/translations/${this.currentLanguage}/`);
            if (response.ok) {
                this.translations = await response.json();
            }
        } catch (error) {
            console.warn('Could not load translations:', error);
        }
    }

    translate(key, fallback = key) {
        return this.translations[key] || fallback;
    }

    getCSRFToken() {
        const token = document.querySelector('[name=csrfmiddlewaretoken]');
        return token ? token.value : '';
    }

    showError(message) {
        // Create error notification
        const notification = document.createElement('div');
        notification.className = 'language-error-notification';
        notification.innerHTML = `
            <div class="error-content">
                <i class="fas fa-exclamation-triangle"></i>
                <span>${message}</span>
            </div>
        `;
        
        // Add error styles
        notification.style.cssText = `
            position: fixed;
            top: 80px;
            right: 20px;
            background: #fee2e2;
            color: #dc2626;
            padding: 12px 20px;
            border-radius: 8px;
            border: 1px solid #fecaca;
            box-shadow: 0 4px 12px rgba(220, 38, 38, 0.15);
            z-index: 1001;
            animation: slideInRight 0.3s ease;
        `;
        
        document.body.appendChild(notification);
        
        // Remove after 3 seconds
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.enhancedLanguageSwitcher = new EnhancedLanguageSwitcher();
});

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = EnhancedLanguageSwitcher;
}