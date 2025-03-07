import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="show-more"
export default class extends Controller {
  static targets = ['item', 'showMoreButton', 'buttonText'];

  connect() {
    this.toggleButtonVisibility();
  }

  toggleItems() {
    const isShowingMore = this.buttonTextTarget.textContent === 'Show less';

    if (isShowingMore) {
      // Hide extra items
      this.itemTargets.forEach((item) => {
        if (item.dataset.hideable === 'true') item.classList.add('hidden');
      });

      this.buttonTextTarget.textContent = 'Show more';

      const scrollOffset = 50;
      this.showMoreButtonTarget.scrollIntoView({ block: 'center' });
      window.scrollBy(0, -scrollOffset);
    } else {
      // Show all items
      this.itemTargets.forEach((item) => {
        item.classList.remove('hidden');
      });

      this.buttonTextTarget.textContent = 'Show less';
    }
  }

  toggleButtonVisibility() {
    const hiddenItems = this.itemTargets.filter((item) => item.classList.contains('hidden'));

    if (hiddenItems.length > 0) {
      this.showMoreButtonTarget.classList.remove('hidden');
    } else {
      this.showMoreButtonTarget.classList.add('hidden');
    }
  }
}
