/**
 * Medical Platform JavaScript
 * نظام JavaScript للمنصة الطبية
 */

class MedicalPlatform {
    constructor() {
        this.init();
    }

    init() {
        this.setupHeader();
        this.setupAnimations();
        this.setupModals();
        this.setupForms();
        this.setupTooltips();
        this.setupSmoothScroll();
        this.setupLazyLoading();
        this.setupProgressBars();
        this.setupNotifications();
    }

    /**
     * Header Setup - إعداد الهيدر
     */
    setupHeader() {
        const header = document.querySelector('.medical-header');
        if (!header) return;

        let lastScrollY = window.scrollY;
        let ticking = false;

        const updateHeader = () => {
            const scrollY = window.scrollY;
            
            // Add scrolled class
            if (scrollY > 50) {
                header.classList.add('scrolled');
            } else {
                header.classList.remove('scrolled');
            }

            // Hide/show header on scroll
            if (scrollY > lastScrollY && scrollY > 100) {
                header.style.transform = 'translateY(-100%)';
            } else {
                header.style.transform = 'translateY(0)';
            }

            lastScrollY = scrollY;
            ticking = false;
        };

        const requestTick = () => {
            if (!ticking) {
                requestAnimationFrame(updateHeader);
                ticking = true;
            }
        };

        window.addEventListener('scroll', requestTick, { passive: true });

        // Mobile menu toggle
        const mobileToggle = document.querySelector('.mobile-menu-toggle');
        const navLinks = document.querySelector('.nav-links');

        if (mobileToggle && navLinks) {
            mobileToggle.addEventListener('click', () => {
                navLinks.classList.toggle('active');
                mobileToggle.classList.toggle('active');
            });
        }

        // Active nav link
        const navLinksElements = document.querySelectorAll('.nav-link');
        const currentPath = window.location.pathname;

        navLinksElements.forEach(link => {
            if (link.getAttribute('href') === currentPath) {
                link.classList.add('active');
            }
        });
    }

    /**
     * Animations Setup - إعداد الحركات
     */
    setupAnimations() {
        // Intersection Observer for animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const element = entry.target;
                    
                    // Add animation class
                    if (element.dataset.animation) {
                        element.classList.add(element.dataset.animation);
                    } else {
                        element.classList.add('animate-fade-in-up');
                    }

                    // Stagger children animations
                    if (element.classList.contains('stagger-children')) {
                        const children = element.children;
                        Array.from(children).forEach((child, index) => {
                            child.style.setProperty('--index', index);
                            child.classList.add('animate-fade-in-up');
                        });
                    }

                    observer.unobserve(element);
                }
            });
        }, observerOptions);

        // Observe elements with animation classes
        const animatedElements = document.querySelectorAll('[data-animation], .animate-on-scroll, .stagger-children');
        animatedElements.forEach(el => observer.observe(el));

        // Parallax effect
        const parallaxElements = document.querySelectorAll('[data-parallax]');
        
        if (parallaxElements.length > 0) {
            let ticking = false;

            const updateParallax = () => {
                const scrollY = window.scrollY;

                parallaxElements.forEach(element => {
                    const speed = parseFloat(element.dataset.parallax) || 0.5;
                    const yPos = -(scrollY * speed);
                    element.style.transform = `translateY(${yPos}px)`;
                });

                ticking = false;
            };

            const requestParallaxTick = () => {
                if (!ticking) {
                    requestAnimationFrame(updateParallax);
                    ticking = true;
                }
            };

            window.addEventListener('scroll', requestParallaxTick, { passive: true });
        }
    }

    /**
     * Modals Setup - إعداد النوافذ المنبثقة
     */
    setupModals() {
        const modalTriggers = document.querySelectorAll('[data-modal]');
        const modals = document.querySelectorAll('.modal-overlay');

        modalTriggers.forEach(trigger => {
            trigger.addEventListener('click', (e) => {
                e.preventDefault();
                const modalId = trigger.dataset.modal;
                const modal = document.getElementById(modalId);
                
                if (modal) {
                    this.openModal(modal);
                }
            });
        });

        modals.forEach(modal => {
            const closeButtons = modal.querySelectorAll('.modal-close, [data-modal-close]');
            
            closeButtons.forEach(button => {
                button.addEventListener('click', () => {
                    this.closeModal(modal);
                });
            });

            // Close on overlay click
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeModal(modal);
                }
            });
        });

        // Close on escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                const activeModal = document.querySelector('.modal-overlay.active');
                if (activeModal) {
                    this.closeModal(activeModal);
                }
            }
        });
    }

    openModal(modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
        
        // Focus trap
        const focusableElements = modal.querySelectorAll(
            'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );
        
        if (focusableElements.length > 0) {
            focusableElements[0].focus();
        }
    }

    closeModal(modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }

    /**
     * Forms Setup - إعداد النماذج
     */
    setupForms() {
        const forms = document.querySelectorAll('form[data-validate]');

        forms.forEach(form => {
            const inputs = form.querySelectorAll('input, select, textarea');

            inputs.forEach(input => {
                // Real-time validation
                input.addEventListener('blur', () => {
                    this.validateField(input);
                });

                input.addEventListener('input', () => {
                    if (input.classList.contains('error')) {
                        this.validateField(input);
                    }
                });
            });

            // Form submission
            form.addEventListener('submit', (e) => {
                let isValid = true;

                inputs.forEach(input => {
                    if (!this.validateField(input)) {
                        isValid = false;
                    }
                });

                if (!isValid) {
                    e.preventDefault();
                    const firstError = form.querySelector('.form-control.error');
                    if (firstError) {
                        firstError.focus();
                        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }
                }
            });
        });

        // File upload preview
        const fileInputs = document.querySelectorAll('input[type="file"][data-preview]');
        fileInputs.forEach(input => {
            input.addEventListener('change', (e) => {
                this.handleFilePreview(e.target);
            });
        });
    }

    validateField(field) {
        const value = field.value.trim();
        const type = field.type;
        const required = field.hasAttribute('required');
        let isValid = true;
        let error = '';

        // Remove existing error
        field.classList.remove('error');
        const existingError = field.parentNode.querySelector('.form-error');
        if (existingError) {
            existingError.remove();
        }

        // Required validation
        if (required && !value) {
            isValid = false;
            error = 'هذا الحقل مطلوب';
        }

        // Email validation
        if (type === 'email' && value) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(value)) {
                isValid = false;
                error = 'يرجى إدخال بريد إلكتروني صحيح';
            }
        }

        // Phone validation
        if (field.name === 'phone' && value) {
            const phoneRegex = /^[\+]?[0-9\s\-\(\)]{10,}$/;
            if (!phoneRegex.test(value)) {
                isValid = false;
                error = 'يرجى إدخال رقم هاتف صحيح';
            }
        }

        // Password validation
        if (type === 'password' && value) {
            if (value.length < 8) {
                isValid = false;
                error = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
            }
        }

        // Password confirmation
        if (field.name === 'password_confirmation' && value) {
            const passwordField = field.form.querySelector('input[name="password"]');
            if (passwordField && value !== passwordField.value) {
                isValid = false;
                error = 'كلمات المرور غير متطابقة';
            }
        }

        // Custom validation
        if (field.dataset.validate) {
            const customValidation = field.dataset.validate;
            // Add custom validation logic here
        }

        if (!isValid) {
            field.classList.add('error');
            const errorElement = document.createElement('span');
            errorElement.className = 'form-error';
            errorElement.textContent = error;
            field.parentNode.appendChild(errorElement);
        }

        return isValid;
    }

    handleFilePreview(input) {
        const file = input.files[0];
        const previewContainer = document.getElementById(input.dataset.preview);

        if (!file || !previewContainer) return;

        if (file.type.startsWith('image/')) {
            const reader = new FileReader();
            reader.onload = (e) => {
                previewContainer.innerHTML = `
                    <img src="${e.target.result}" alt="Preview" class="max-w-full h-auto rounded-lg">
                `;
            };
            reader.readAsDataURL(file);
        } else {
            previewContainer.innerHTML = `
                <div class="flex items-center gap-3 p-4 bg-neutral-100 rounded-lg">
                    <i class="fas fa-file text-2xl text-neutral-500"></i>
                    <span class="font-medium">${file.name}</span>
                </div>
            `;
        }
    }

    /**
     * Tooltips Setup - إعداد التلميحات
     */
    setupTooltips() {
        const tooltipElements = document.querySelectorAll('[data-tooltip]');

        tooltipElements.forEach(element => {
            let tooltip = null;

            const showTooltip = (e) => {
                const text = element.dataset.tooltip;
                const position = element.dataset.tooltipPosition || 'top';

                tooltip = document.createElement('div');
                tooltip.className = `tooltip tooltip-${position}`;
                tooltip.textContent = text;
                document.body.appendChild(tooltip);

                const rect = element.getBoundingClientRect();
                const tooltipRect = tooltip.getBoundingClientRect();

                let top, left;

                switch (position) {
                    case 'top':
                        top = rect.top - tooltipRect.height - 8;
                        left = rect.left + (rect.width - tooltipRect.width) / 2;
                        break;
                    case 'bottom':
                        top = rect.bottom + 8;
                        left = rect.left + (rect.width - tooltipRect.width) / 2;
                        break;
                    case 'left':
                        top = rect.top + (rect.height - tooltipRect.height) / 2;
                        left = rect.left - tooltipRect.width - 8;
                        break;
                    case 'right':
                        top = rect.top + (rect.height - tooltipRect.height) / 2;
                        left = rect.right + 8;
                        break;
                }

                tooltip.style.top = `${top}px`;
                tooltip.style.left = `${left}px`;
                tooltip.classList.add('active');
            };

            const hideTooltip = () => {
                if (tooltip) {
                    tooltip.remove();
                    tooltip = null;
                }
            };

            element.addEventListener('mouseenter', showTooltip);
            element.addEventListener('mouseleave', hideTooltip);
            element.addEventListener('focus', showTooltip);
            element.addEventListener('blur', hideTooltip);
        });
    }

    /**
     * Smooth Scroll Setup - إعداد التمرير السلس
     */
    setupSmoothScroll() {
        const scrollLinks = document.querySelectorAll('a[href^="#"]');

        scrollLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                const href = link.getAttribute('href');
                if (href === '#') return;

                const target = document.querySelector(href);
                if (target) {
                    e.preventDefault();
                    
                    const headerHeight = document.querySelector('.medical-header')?.offsetHeight || 0;
                    const targetPosition = target.offsetTop - headerHeight - 20;

                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                }
            });
        });
    }

    /**
     * Lazy Loading Setup - إعداد التحميل التدريجي
     */
    setupLazyLoading() {
        const lazyImages = document.querySelectorAll('img[data-src]');

        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        img.src = img.dataset.src;
                        img.classList.remove('lazy');
                        imageObserver.unobserve(img);
                    }
                });
            });

            lazyImages.forEach(img => imageObserver.observe(img));
        } else {
            // Fallback for older browsers
            lazyImages.forEach(img => {
                img.src = img.dataset.src;
                img.classList.remove('lazy');
            });
        }
    }

    /**
     * Progress Bars Setup - إعداد أشرطة التقدم
     */
    setupProgressBars() {
        const progressBars = document.querySelectorAll('.progress-bar[data-progress]');

        const progressObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const bar = entry.target;
                    const progress = parseInt(bar.dataset.progress);
                    
                    setTimeout(() => {
                        bar.style.width = `${progress}%`;
                    }, 200);

                    progressObserver.unobserve(bar);
                }
            });
        });

        progressBars.forEach(bar => progressObserver.observe(bar));
    }

    /**
     * Notifications Setup - إعداد الإشعارات
     */
    setupNotifications() {
        // Auto-hide alerts
        const alerts = document.querySelectorAll('.alert[data-auto-hide]');
        alerts.forEach(alert => {
            const delay = parseInt(alert.dataset.autoHide) || 5000;
            setTimeout(() => {
                alert.style.opacity = '0';
                alert.style.transform = 'translateY(-20px)';
                setTimeout(() => alert.remove(), 300);
            }, delay);
        });
    }

    /**
     * Utility Methods - طرق مساعدة
     */
    showNotification(message, type = 'info', duration = 5000) {
        const notification = document.createElement('div');
        notification.className = `alert alert-${type} fixed top-4 right-4 z-50 max-w-sm animate-slide-in-right`;
        notification.innerHTML = `
            <div class="alert-icon">
                <i class="fas fa-${this.getNotificationIcon(type)}"></i>
            </div>
            <div class="alert-content">
                <div class="alert-message">${message}</div>
            </div>
            <button class="alert-close ml-2" onclick="this.parentElement.remove()">
                <i class="fas fa-times"></i>
            </button>
        `;

        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.opacity = '0';
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => notification.remove(), 300);
        }, duration);
    }

    getNotificationIcon(type) {
        const icons = {
            success: 'check-circle',
            error: 'exclamation-circle',
            warning: 'exclamation-triangle',
            info: 'info-circle'
        };
        return icons[type] || 'info-circle';
    }

    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    throttle(func, limit) {
        let inThrottle;
        return function() {
            const args = arguments;
            const context = this;
            if (!inThrottle) {
                func.apply(context, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.medicalPlatform = new MedicalPlatform();
});

// Add CSS for tooltips
const tooltipStyles = `
    .tooltip {
        position: absolute;
        background: var(--neutral-900);
        color: white;
        padding: var(--space-2) var(--space-3);
        border-radius: var(--radius-md);
        font-size: var(--text-sm);
        font-weight: var(--font-medium);
        z-index: var(--z-tooltip);
        opacity: 0;
        pointer-events: none;
        transition: opacity var(--duration-200) var(--ease-out);
        white-space: nowrap;
        box-shadow: var(--shadow-lg);
    }

    .tooltip.active {
        opacity: 1;
    }

    .tooltip::before {
        content: '';
        position: absolute;
        width: 0;
        height: 0;
        border: 4px solid transparent;
    }

    .tooltip-top::before {
        bottom: -8px;
        left: 50%;
        transform: translateX(-50%);
        border-top-color: var(--neutral-900);
    }

    .tooltip-bottom::before {
        top: -8px;
        left: 50%;
        transform: translateX(-50%);
        border-bottom-color: var(--neutral-900);
    }

    .tooltip-left::before {
        right: -8px;
        top: 50%;
        transform: translateY(-50%);
        border-left-color: var(--neutral-900);
    }

    .tooltip-right::before {
        left: -8px;
        top: 50%;
        transform: translateY(-50%);
        border-right-color: var(--neutral-900);
    }

    .lazy {
        opacity: 0;
        transition: opacity var(--duration-300) var(--ease-out);
    }

    .lazy.loaded {
        opacity: 1;
    }
`;

// Inject tooltip styles
const styleSheet = document.createElement('style');
styleSheet.textContent = tooltipStyles;
document.head.appendChild(styleSheet);