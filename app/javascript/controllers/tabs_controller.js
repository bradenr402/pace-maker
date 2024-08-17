import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="tabs"
export default class extends Controller {
  static classes = ['active'];
  static targets = ['btn', 'tab'];
  static values = { defaultTab: String };

  connect() {
    // Get the initial tab from the URL tab parameter
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');

    const initialTab = tabParam || this.defaultTabValue;

    this.tabTargets.forEach((tab) => {
      tab.hidden = true;
      tab.classList.add('hidden');
    });

    const selectedTab = this.tabTargets.find((tab) => tab.id === initialTab);

    if (selectedTab) {
      selectedTab.hidden = false;
      selectedTab.classList.remove('hidden');
    }

    const selectedBtn = this.btnTargets.find((btn) => btn.id === initialTab);

    if (selectedBtn) {
      selectedBtn.classList.add(...this.activeClasses);

      this.scrollToTab(selectedTab);
    }
  }

  select(event) {
    const selectedTab = this.tabTargets.find(
      (tab) => tab.id === event.currentTarget.id
    );

    if (selectedTab.hidden) {
      this.tabTargets.forEach((tab) => {
        tab.hidden = true;
        tab.classList.add('hidden');
      });

      this.btnTargets.forEach((btn) =>
        btn.classList.remove(...this.activeClasses)
      );

      selectedTab.hidden = false;
      selectedTab.classList.remove('hidden');
      event.currentTarget.classList.add(...this.activeClasses);

      // Update URL with the selected tab parameter
      const url = new URL(window.location);
      url.searchParams.set('tab', event.currentTarget.id);
      window.history.replaceState({}, '', url);

      this.scrollToTab(event.currentTarget);
    }
  }

  scrollToTab(tab) {
    // Get the container element that holds the tabs (assuming it has a horizontal overflow)
    const container = document.querySelector('.tab-container');

    if (!container || !tab) return;

    // Calculate the position of the tab within the container
    const tabRect = tab.getBoundingClientRect();
    const containerRect = container.getBoundingClientRect();

    // Calculate the horizontal scroll position needed to center the tab
    const scrollLeft =
      tabRect.left -
      containerRect.left +
      container.scrollLeft -
      containerRect.width / 2 +
      tabRect.width / 2;

    // Smoothly scroll horizontally to the calculated position
    container.scrollTo({
      left: scrollLeft,
      behavior: 'smooth',
    });
  }
}
