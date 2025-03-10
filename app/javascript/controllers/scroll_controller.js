import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="scroll"
export default class extends Controller {
  static targets = ['loadMoreButton'];

  scrollToTarget(event) {
    const target = document.getElementById(event.currentTarget.dataset.scrollTargetId);

    if (target) {
      const offset = 50;

      target.scrollIntoView({ behavior: 'smooth', block: 'center' });

      window.scrollBy(0, -offset);

      setTimeout(() => {
        target.classList.add('motion-safe:attention-animation');
      }, 200);

      setTimeout(() => {
        target.classList.remove('motion-safe:attention-animation');
      }, 1200);
    } else {
      this.loadMoreButtonTarget.scrollIntoView({ behavior: 'smooth', block: 'center' });

      setTimeout(() => {
        this.loadMoreButtonTarget.classList.add('motion-safe:pulse-hover-animation');
      }, 350);

      setTimeout(() => {
        this.loadMoreButtonTarget.classList.remove('motion-safe:pulse-hover-animation');
      }, 1350);
    }
  }
}
