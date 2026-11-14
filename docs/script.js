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

    document.addEventListener('click', (event) => {
        if (!mobileMenuBtn.contains(event.target) && !navLinks.contains(event.target)) {
            if (window.innerWidth <= 768) {
                navLinks.style.display = 'none';
            }
        }
    });

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

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const targetId = this.getAttribute('href');
        if (!targetId || targetId === '#') return;
        const targetElement = document.querySelector(targetId);
        if (!targetElement) return;
        e.preventDefault();
        if (window.innerWidth <= 768 && navLinks) {
            navLinks.style.display = 'none';
        }
        window.scrollTo({
            top: targetElement.offsetTop - 80,
            behavior: 'smooth'
        });
    });
});
