// Admin Panel JavaScript - Enhanced Version

document.addEventListener('DOMContentLoaded', function() {
    // Initialize all components
    initializeComponents();
    
    // Initialize responsive features
    initializeResponsive();
    
    // Initialize animations
    initializeAnimations();
    
    // Initialize utilities
    initializeUtilities();
});

function initializeComponents() {
    // Initialize Bootstrap components
    initializeBootstrapComponents();
    
    // Initialize custom components
    initializeCustomComponents();
    
    // Initialize form enhancements
    initializeFormEnhancements();
    
    // Initialize table enhancements
    initializeTableEnhancements();
}

function initializeBootstrapComponents() {
    // Initialize tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Initialize popovers
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });

    // Initialize modals
    const modalElements = document.querySelectorAll('.modal');
    modalElements.forEach(function(modalEl) {
        const modal = new bootstrap.Modal(modalEl);
        
        modalEl.addEventListener('show.bs.modal', function() {
            document.body.classList.add('modal-open');
        });
        
        modalEl.addEventListener('hidden.bs.modal', function() {
            document.body.classList.remove('modal-open');
        });
    });
}

function initializeCustomComponents() {
    // Sidebar toggle for mobile
    initializeSidebar();
    
    // Auto-hide alerts
    initializeAlerts();
    
    // Confirm delete actions
    initializeDeleteConfirmation();
    
    // Loading states
    initializeLoadingStates();
}

function initializeSidebar() {
    const sidebarToggle = document.querySelector('.sidebar-toggle');
    const sidebar = document.querySelector('.admin-sidebar');
    const overlay = document.querySelector('.admin-overlay');
    
    // Create mobile menu button if it doesn't exist
    if (!sidebarToggle && window.innerWidth <= 992) {
        createMobileMenuButton();
    }
    
    // Handle sidebar toggle
    document.addEventListener('click', function(e) {
        if (e.target.matches('.sidebar-toggle, .mobile-menu-btn')) {
            e.preventDefault();
            toggleSidebar();
        }
        
        if (e.target.matches('.admin-overlay')) {
            closeSidebar();
        }
    });
    
    // Close sidebar on window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth > 992) {
            closeSidebar();
        }
    });
}

function createMobileMenuButton() {
    const button = document.createElement('button');
    button.className = 'mobile-menu-btn';
    button.innerHTML = '<i class="fas fa-bars"></i>';
    button.setAttribute('aria-label', 'فتح القائمة');
    button.style.cssText = `
        position: fixed;
        top: 1rem;
        right: 1rem;
        z-index: 1001;
        background: var(--primary-gradient, #667eea);
        color: white;
        border: none;
        border-radius: 50%;
        width: 50px;
        height: 50px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        display: flex;
        align-items: center;
        justify-content: center;
    `;
    document.body.appendChild(button);
}

function toggleSidebar() {
    const sidebar = document.querySelector('.admin-sidebar');
    const overlay = document.querySelector('.admin-overlay') || createOverlay();
    
    sidebar.classList.toggle('show');
    overlay.classList.toggle('show');
    document.body.classList.toggle('sidebar-open');
}

function closeSidebar() {
    const sidebar = document.querySelector('.admin-sidebar');
    const overlay = document.querySelector('.admin-overlay');
    
    if (sidebar) sidebar.classList.remove('show');
    if (overlay) overlay.classList.remove('show');
    document.body.classList.remove('sidebar-open');
}

function createOverlay() {
    const overlay = document.createElement('div');
    overlay.className = 'admin-overlay';
    overlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        z-index: 999;
        display: none;
    `;
    document.body.appendChild(overlay);
    return overlay;
}

function initializeAlerts() {
    const alerts = document.querySelectorAll('.alert:not(.alert-permanent)');
    
    alerts.forEach(function(alert) {
        // Add close button if not exists
        if (!alert.querySelector('.btn-close')) {
            const closeBtn = document.createElement('button');
            closeBtn.className = 'btn-close';
            closeBtn.setAttribute('data-bs-dismiss', 'alert');
            closeBtn.setAttribute('aria-label', 'إغلاق');
            alert.appendChild(closeBtn);
        }
        
        // Auto-hide after 5 seconds
        setTimeout(function() {
            if (alert.parentElement) {
                alert.style.opacity = '0';
                alert.style.transform = 'translateY(-20px)';
                setTimeout(function() {
                    if (alert.parentElement) {
                        alert.remove();
                    }
                }, 300);
            }
        }, 5000);
    });
}

function initializeDeleteConfirmation() {
    document.addEventListener('click', function(e) {
        if (e.target.matches('.btn-delete, .delete-btn, [data-action="delete"]')) {
            e.preventDefault();
            
            const message = e.target.getAttribute('data-confirm-message') || 'هل أنت متأكد من الحذف؟';
            
            if (confirm(message)) {
                // If it's a form button, submit the form
                if (e.target.type === 'submit') {
                    e.target.closest('form').submit();
                }
                // If it's a link, follow the link
                else if (e.target.tagName === 'A') {
                    window.location.href = e.target.href;
                }
            }
        }
    });
}

function initializeLoadingStates() {
    document.addEventListener('click', function(e) {
        if (e.target.matches('.btn-loading, [data-loading="true"]')) {
            const button = e.target;
            const originalText = button.innerHTML;
            const loadingText = button.getAttribute('data-loading-text') || 'جاري التحميل...';
            
            button.innerHTML = `<i class="fas fa-spinner fa-spin me-2"></i>${loadingText}`;
            button.disabled = true;
            
            // Reset after 10 seconds (fallback)
            setTimeout(function() {
                button.innerHTML = originalText;
                button.disabled = false;
            }, 10000);
        }
    });
}

function initializeFormEnhancements() {
    // Form validation
    const forms = document.querySelectorAll('.needs-validation');
    forms.forEach(function(form) {
        form.addEventListener('submit', function(event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
                
                // Focus on first invalid field
                const firstInvalid = form.querySelector(':invalid');
                if (firstInvalid) {
                    firstInvalid.focus();
                }
            }
            form.classList.add('was-validated');
        });
    });
    
    // Real-time validation
    const inputs = document.querySelectorAll('input, textarea, select');
    inputs.forEach(function(input) {
        input.addEventListener('blur', function() {
            if (this.checkValidity()) {
                this.classList.remove('is-invalid');
                this.classList.add('is-valid');
            } else {
                this.classList.remove('is-valid');
                this.classList.add('is-invalid');
            }
        });
        
        input.addEventListener('input', function() {
            if (this.classList.contains('is-invalid') && this.checkValidity()) {
                this.classList.remove('is-invalid');
                this.classList.add('is-valid');
            }
        });
    });
}

function initializeTableEnhancements() {
    // Table search functionality
    const searchInputs = document.querySelectorAll('.table-search, [data-table-search]');
    searchInputs.forEach(function(input) {
        input.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const tableId = this.getAttribute('data-table-target');
            const table = tableId ? document.querySelector(tableId) : this.closest('.card').querySelector('table');
            
            if (table) {
                searchTable(table, searchTerm);
            }
        });
    });
    
    // Table sorting
    initializeTableSorting();
    
    // Table row selection
    initializeTableSelection();
}

function searchTable(table, searchTerm) {
    const tbody = table.querySelector('tbody');
    const rows = tbody.querySelectorAll('tr');
    let visibleCount = 0;
    
    rows.forEach(function(row) {
        const text = row.textContent.toLowerCase();
        if (text.includes(searchTerm)) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });
    
    // Show/hide no results message
    showNoResultsMessage(tbody, visibleCount === 0 && searchTerm.length > 0);
}

function showNoResultsMessage(tbody, show) {
    let noResultsRow = tbody.querySelector('.no-results-row');
    
    if (show && !noResultsRow) {
        const colCount = tbody.closest('table').querySelectorAll('thead th').length;
        noResultsRow = document.createElement('tr');
        noResultsRow.className = 'no-results-row';
        noResultsRow.innerHTML = `
            <td colspan="${colCount}" class="text-center py-4">
                <div class="text-muted">
                    <i class="fas fa-search fa-2x mb-2"></i>
                    <br>
                    لا توجد نتائج مطابقة
                </div>
            </td>
        `;
        tbody.appendChild(noResultsRow);
    } else if (!show && noResultsRow) {
        noResultsRow.remove();
    }
}

function initializeTableSorting() {
    const sortableHeaders = document.querySelectorAll('th[data-sortable="true"], .sortable');
    
    sortableHeaders.forEach(function(header, index) {
        header.style.cursor = 'pointer';
        header.addEventListener('click', function() {
            sortTable(this, index);
        });
        
        // Add sort icon if not exists
        if (!header.querySelector('.sort-icon')) {
            const icon = document.createElement('i');
            icon.className = 'fas fa-sort sort-icon ms-2';
            header.appendChild(icon);
        }
    });
}

function sortTable(header, columnIndex) {
    const table = header.closest('table');
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr:not(.no-results-row)'));
    
    const currentDirection = table.dataset.sortDirection || 'none';
    const newDirection = currentDirection === 'asc' ? 'desc' : 'asc';
    
    table.dataset.sortDirection = newDirection;
    table.dataset.sortColumn = columnIndex;
    
    rows.sort(function(a, b) {
        const aText = a.cells[columnIndex]?.textContent.trim() || '';
        const bText = b.cells[columnIndex]?.textContent.trim() || '';
        
        const aNum = parseFloat(aText.replace(/[^\d.-]/g, ''));
        const bNum = parseFloat(bText.replace(/[^\d.-]/g, ''));
        
        let comparison = 0;
        
        if (!isNaN(aNum) && !isNaN(bNum)) {
            comparison = aNum - bNum;
        } else {
            comparison = aText.localeCompare(bText, 'ar', { numeric: true });
        }
        
        return newDirection === 'asc' ? comparison : -comparison;
    });
    
    // Re-append sorted rows
    rows.forEach(function(row) {
        tbody.appendChild(row);
    });
    
    // Update sort icons
    updateSortIcons(table, columnIndex, newDirection);
}

function updateSortIcons(table, activeColumn, direction) {
    const headers = table.querySelectorAll('th');
    
    headers.forEach(function(header, index) {
        const icon = header.querySelector('.sort-icon');
        if (icon) {
            if (index === activeColumn) {
                icon.className = direction === 'asc' ? 
                    'fas fa-sort-up sort-icon ms-2' : 
                    'fas fa-sort-down sort-icon ms-2';
                icon.style.color = 'var(--primary-color)';
            } else {
                icon.className = 'fas fa-sort sort-icon ms-2';
                icon.style.color = '';
            }
        }
    });
}

function initializeTableSelection() {
    // Select all functionality
    const selectAllCheckboxes = document.querySelectorAll('.select-all');
    selectAllCheckboxes.forEach(function(checkbox) {
        checkbox.addEventListener('change', function() {
            const table = this.closest('table');
            const rowCheckboxes = table.querySelectorAll('.row-select');
            
            rowCheckboxes.forEach(function(rowCheckbox) {
                rowCheckbox.checked = checkbox.checked;
                toggleRowSelection(rowCheckbox.closest('tr'), checkbox.checked);
            });
        });
    });
    
    // Individual row selection
    document.addEventListener('change', function(e) {
        if (e.target.matches('.row-select')) {
            const row = e.target.closest('tr');
            const table = e.target.closest('table');
            const selectAllCheckbox = table.querySelector('.select-all');
            
            toggleRowSelection(row, e.target.checked);
            updateSelectAllState(table, selectAllCheckbox);
        }
    });
}

function toggleRowSelection(row, selected) {
    if (selected) {
        row.classList.add('table-row-selected');
    } else {
        row.classList.remove('table-row-selected');
    }
}

function updateSelectAllState(table, selectAllCheckbox) {
    if (!selectAllCheckbox) return;
    
    const rowCheckboxes = table.querySelectorAll('.row-select');
    const checkedCount = table.querySelectorAll('.row-select:checked').length;
    
    if (checkedCount === 0) {
        selectAllCheckbox.indeterminate = false;
        selectAllCheckbox.checked = false;
    } else if (checkedCount === rowCheckboxes.length) {
        selectAllCheckbox.indeterminate = false;
        selectAllCheckbox.checked = true;
    } else {
        selectAllCheckbox.indeterminate = true;
    }
}

function initializeResponsive() {
    // Handle window resize
    window.addEventListener('resize', function() {
        handleResponsiveChanges();
    });
    
    // Initial responsive setup
    handleResponsiveChanges();
}

function handleResponsiveChanges() {
    const isMobile = window.innerWidth <= 768;
    const isTablet = window.innerWidth <= 992;
    
    // Show/hide mobile menu button
    const mobileBtn = document.querySelector('.mobile-menu-btn');
    if (mobileBtn) {
        mobileBtn.style.display = isTablet ? 'flex' : 'none';
    }
    
    // Adjust table display for mobile
    const tables = document.querySelectorAll('.table');
    tables.forEach(function(table) {
        if (isMobile) {
            table.classList.add('table-sm');
        } else {
            table.classList.remove('table-sm');
        }
    });
    
    // Adjust card padding for mobile
    const cards = document.querySelectorAll('.card-body');
    cards.forEach(function(card) {
        if (isMobile) {
            card.style.padding = '1rem';
        } else {
            card.style.padding = '';
        }
    });
}

function initializeAnimations() {
    // Fade in animation for new elements
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in');
                observer.unobserve(entry.target);
            }
        });
    });
    
    // Observe elements with animation class
    const animatedElements = document.querySelectorAll('.animate-on-scroll');
    animatedElements.forEach(function(el) {
        observer.observe(el);
    });
}

function initializeUtilities() {
    // Smooth scrolling for anchor links
    document.addEventListener('click', function(e) {
        if (e.target.matches('a[href^="#"]')) {
            e.preventDefault();
            const target = document.querySelector(e.target.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        }
    });
    
    // Copy to clipboard functionality
    document.addEventListener('click', function(e) {
        if (e.target.matches('[data-copy]')) {
            const text = e.target.getAttribute('data-copy');
            navigator.clipboard.writeText(text).then(function() {
                showNotification('تم النسخ بنجاح', 'success');
            });
        }
    });
    
    // Auto-refresh functionality
    const autoRefreshElements = document.querySelectorAll('[data-auto-refresh]');
    autoRefreshElements.forEach(function(element) {
        const interval = parseInt(element.getAttribute('data-auto-refresh')) || 30000;
        setInterval(function() {
            refreshElement(element);
        }, interval);
    });
}

function refreshElement(element) {
    // Add refresh logic here
    console.log('Refreshing element:', element);
}

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `alert alert-${type} alert-dismissible fade show notification-toast`;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 1060;
        min-width: 300px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    `;
    notification.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(notification);
    
    // Auto-remove after 5 seconds
    setTimeout(function() {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 5000);
}

// Add CSS for enhanced functionality
const enhancedStyles = document.createElement('style');
enhancedStyles.textContent = `
.table-row-selected {
    background-color: rgba(102, 126, 234, 0.1) !important;
}

.admin-overlay.show {
    display: block !important;
}

.admin-sidebar.show {
    transform: translateX(0) !important;
}

.fade-in {
    animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

.notification-toast {
    animation: slideInRight 0.3s ease;
}

@keyframes slideInRight {
    from { opacity: 0; transform: translateX(100%); }
    to { opacity: 1; transform: translateX(0); }
}

.sort-icon {
    opacity: 0.5;
    transition: all 0.3s ease;
}

.sort-icon:hover {
    opacity: 1;
}

@media (max-width: 992px) {
    .admin-sidebar {
        transform: translateX(100%);
        transition: transform 0.3s ease;
    }
    
    .main-content {
        margin-right: 0 !important;
    }
}
`;
document.head.appendChild(enhancedStyles);

// Global utility functions
window.AdminPanel = {
    showNotification: showNotification,
    toggleSidebar: toggleSidebar,
    closeSidebar: closeSidebar,
    searchTable: searchTable,
    sortTable: sortTable
};