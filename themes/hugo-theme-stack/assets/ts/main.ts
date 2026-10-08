/*!
 *   Hugo Theme Stack
 *
 *   @author: Jimmy Cai
 *   @website: https://jimmycai.com
 *   @link: https://github.com/CaiJimmy/hugo-theme-stack
 */
import menu from 'ts/menu';
import createElement from 'ts/createElement';
import StackColorScheme from 'ts/colorScheme';
import { setupScrollspy } from 'ts/scrollspy';
import { setupSmoothAnchors } from "ts/smoothAnchors";

let Stack = {
    init: () => {
        /**
         * Bind menu event
         */
        menu();

        const articleContent = document.querySelector('.article-content') as HTMLElement;
        if (articleContent) {
            setupSmoothAnchors();
            setupScrollspy();
        }

        /**
         * Add copy button to code block
         */
        const highlights = document.querySelectorAll('.article-content div.highlight');
        const copyText = `Copy`,
            copiedText = `Copied!`;

        highlights.forEach(highlight => {
            const copyButton = document.createElement('button');
            copyButton.innerHTML = copyText;
            copyButton.classList.add('copyCodeButton');
            highlight.appendChild(copyButton);

            const codeBlock = highlight.querySelector('code[data-lang]');
            if (!codeBlock) return;

            copyButton.addEventListener('click', () => {
                navigator.clipboard.writeText(codeBlock.textContent)
                    .then(() => {
                        copyButton.textContent = copiedText;

                        setTimeout(() => {
                            copyButton.textContent = copyText;
                        }, 1000);
                    })
                    .catch(err => {
                        alert(err)
                        console.log('Something went wrong', err);
                    });
            });
        });

        new StackColorScheme(document.getElementById('dark-mode-toggle'));

        /**
         * Related content keyboard navigation
         */
        const relatedTracks = document.querySelectorAll('.related-content__track');
        relatedTracks.forEach(track => {
            const prevBtn = track.parentElement?.querySelector('.related-nav--prev') as HTMLButtonElement;
            const nextBtn = track.parentElement?.querySelector('.related-nav--next') as HTMLButtonElement;
            const scrollAmount = 265; // article width (250) + gap (15)

            const scroll = (direction: number) => {
                track.scrollBy({ left: direction * scrollAmount, behavior: 'smooth' });
            };

            prevBtn?.addEventListener('click', () => scroll(-1));
            nextBtn?.addEventListener('click', () => scroll(1));

            // Keyboard navigation when track is focused
            track.addEventListener('keydown', (e: KeyboardEvent) => {
                if (e.key === 'ArrowLeft') {
                    e.preventDefault();
                    scroll(-1);
                } else if (e.key === 'ArrowRight') {
                    e.preventDefault();
                    scroll(1);
                }
            });

            // Also allow keyboard navigation on buttons
            [prevBtn, nextBtn].forEach(btn => {
                btn?.addEventListener('keydown', (e: KeyboardEvent) => {
                    if (e.key === 'ArrowLeft') {
                        e.preventDefault();
                        scroll(-1);
                    } else if (e.key === 'ArrowRight') {
                        e.preventDefault();
                        scroll(1);
                    }
                });
            });
        });
    }
}

window.addEventListener('load', () => {
    setTimeout(function () {
        Stack.init();
    }, 0);
})

declare global {
    interface Window {
        createElement: any;
        Stack: any
    }
}

window.Stack = Stack;
window.createElement = createElement;
