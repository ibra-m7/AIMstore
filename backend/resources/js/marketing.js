import "bootstrap-icons/font/bootstrap-icons.css";
import "../css/marketing.css";

document.querySelectorAll('.mkt-faq-item').forEach((item) => {
    item.addEventListener('toggle', () => {
        if (!item.open) {
            return;
        }
        document.querySelectorAll('.mkt-faq-item').forEach((other) => {
            if (other !== item) {
                other.open = false;
            }
        });
    });
});

document.querySelectorAll('a[href^="#"]').forEach((link) => {
    link.addEventListener('click', (event) => {
        const id = link.getAttribute('href');
        if (!id || id === '#') {
            return;
        }
        const target = document.querySelector(id);
        if (!target) {
            return;
        }
        event.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
});
