// LLM Proxy - Landing Page Module
// ESM Vanilla JavaScript

/**
 * Navigation scroll effect
 */
function initNavScroll() {
  const nav = document.querySelector('.nav');
  if (!nav) return;

  const onScroll = () => {
    if (window.scrollY > 10) {
      nav.classList.add('scrolled');
    } else {
      nav.classList.remove('scrolled');
    }
  };

  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
}

/**
 * Mobile menu toggle
 */
function initMobileMenu() {
  const btn = document.querySelector('.nav-menu-btn');
  const links = document.querySelector('.nav-links');
  if (!btn || !links) return;

  btn.addEventListener('click', () => {
    links.classList.toggle('open');
    const isOpen = links.classList.contains('open');
    btn.setAttribute('aria-expanded', isOpen);
  });

  // Close menu when a link is clicked
  links.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      links.classList.remove('open');
      btn.setAttribute('aria-expanded', 'false');
    });
  });
}

/**
 * Scroll-triggered animations using IntersectionObserver
 */
function initAnimations() {
  const elements = document.querySelectorAll('.animate-in');
  if (!elements.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    }
  );

  elements.forEach(el => observer.observe(el));
}

/**
 * Smooth scroll for anchor links
 */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', (e) => {
      const targetId = anchor.getAttribute('href');
      if (targetId === '#') return;

      const target = document.querySelector(targetId);
      if (!target) return;

      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
}

/**
 * Typing animation for the code preview
 */
function initCodeTyping() {
  const codeBlock = document.querySelector('.code-body');
  if (!codeBlock) return;

  const originalHTML = codeBlock.innerHTML;
  codeBlock.innerHTML = '';
  codeBlock.style.minHeight = '200px';

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          typeCode(codeBlock, originalHTML);
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.3 }
  );

  observer.observe(codeBlock);
}

/**
 * Type code with HTML preservation
 */
function typeCode(element, html) {
  let i = 0;
  let currentHTML = '';
  let inTag = false;
  const speed = 12;

  function type() {
    if (i < html.length) {
      const char = html[i];

      if (char === '<') {
        inTag = true;
        const closeIndex = html.indexOf('>', i);
        currentHTML += html.substring(i, closeIndex + 1);
        i = closeIndex + 1;
      } else if (char === '&') {
        const semiIndex = html.indexOf(';', i);
        currentHTML += html.substring(i, semiIndex + 1);
        i = semiIndex + 1;
      } else {
        currentHTML += char;
        i++;
      }

      element.innerHTML = currentHTML;

      if (!inTag) {
        setTimeout(type, speed);
      } else {
        inTag = false;
        type();
      }
    }
  }

  // Small delay before starting
  setTimeout(type, 500);
}

/**
 * Initialize all modules
 */
function init() {
  initNavScroll();
  initMobileMenu();
  initAnimations();
  initSmoothScroll();
  initCodeTyping();
}

// Run when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}

export { init };
