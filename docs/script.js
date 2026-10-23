// Mobile Menu Toggle
const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuBtn && navLinks) {
    mobileMenuBtn.addEventListener('click', () => {
        navLinks.style.display = navLinks.style.display === 'flex' ? 'none' : 'flex';
        navLinks.style.flexDirection = 'column';
        navLinks.style.position = 'absolute';
        navLinks.style.top = '100%';
        navLinks.style.left = '0';
        navLinks.style.right = '0';
        navLinks.style.backgroundColor = 'white';
        navLinks.style.padding = 'var(--spacing-lg)';
        navLinks.style.boxShadow = 'var(--shadow-md)';
        navLinks.style.gap = 'var(--spacing-md)';
    });

    // Close menu when clicking outside
    document.addEventListener('click', (event) => {
        if (!mobileMenuBtn.contains(event.target) && !navLinks.contains(event.target)) {
            if (window.innerWidth <= 768) {
                navLinks.style.display = 'none';
            }
        }
    });

    // Handle window resize
    window.addEventListener('resize', () => {
        if (window.innerWidth > 768) {
            navLinks.style.display = 'flex';
            navLinks.style.flexDirection = 'row';
            navLinks.style.position = 'static';
            navLinks.style.backgroundColor = 'transparent';
            navLinks.style.padding = '0';
            navLinks.style.boxShadow = 'none';
        } else {
            navLinks.style.display = 'none';
        }
    });
}

// Smooth scroll for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const targetId = this.getAttribute('href');
        if (targetId === '#') return;
        
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            // Close mobile menu if open
            if (window.innerWidth <= 768 && navLinks) {
                navLinks.style.display = 'none';
            }
            
            window.scrollTo({
                top: targetElement.offsetTop - 80,
                behavior: 'smooth'
            });
        }
    });
});

// Animate ACWR chart needle
const animateACWRChart = () => {
    const needle = document.querySelector('.chart-needle');
    if (!needle) return;
    
    // Reset to initial position
    needle.style.transform = 'translateX(-50%) rotate(-90deg)';
    
    // Animate to target position (45deg = ACWR 1.12)
    setTimeout(() => {
        needle.style.transition = 'transform 1.5s ease-in-out';
        needle.style.transform = 'translateX(-50%) rotate(45deg)';
    }, 500);
};

// Waitlist form submission
const setupWaitlistForms = () => {
    const waitlistButtons = document.querySelectorAll('.primary-button[href="#"]');
    
    waitlistButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            
            // Determine platform based on button text
            const platform = button.textContent.includes('iOS') ? 'iOS' : 'Android';
            
            // Show simple alert (in a real implementation, this would open a form)
            alert(`Thank you for your interest! Cross ${platform} version is currently in development.\n\nJoin our waitlist at: https://github.com/cubecnelson/cross_app\n\nYou'll be notified when ${platform} testing begins.`);
        });
    });
};

// Scroll animation for features
const animateOnScroll = () => {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, observerOptions);

    // Observe feature cards
    document.querySelectorAll('.feature-card').forEach(card => {
        observer.observe(card);
    });
};

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Initialize mobile menu
    if (window.innerWidth <= 768 && navLinks) {
        navLinks.style.display = 'none';
    }

    // Animate ACWR chart
    animateACWRChart();

    // Setup waitlist forms
    setupWaitlistForms();

    // Setup scroll animations
    animateOnScroll();

    // Add CSS for animations
    const style = document.createElement('style');
    style.textContent = `
        .feature-card {
            opacity: 0;
            transform: translateY(30px);
            transition: opacity 0.6s ease, transform 0.6s ease;
        }
        
        .feature-card.animate-in {
            opacity: 1;
            transform: translateY(0);
        }
        
        .feature-card:nth-child(2) { transition-delay: 0.1s; }
        .feature-card:nth-child(3) { transition-delay: 0.2s; }
        .feature-card:nth-child(4) { transition-delay: 0.3s; }
        .feature-card:nth-child(5) { transition-delay: 0.4s; }
        .feature-card:nth-child(6) { transition-delay: 0.5s; }
    `;
    document.head.appendChild(style);
});

// Update current year in footer
const updateFooterYear = () => {
    const yearElement = document.querySelector('footer .footer-bottom p');
    if (yearElement) {
        const currentYear = new Date().getFullYear();
        yearElement.innerHTML = yearElement.innerHTML.replace('2026', currentYear);
    }
};

// Initialize year update
updateFooterYear();