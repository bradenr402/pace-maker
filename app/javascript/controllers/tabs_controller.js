import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="tabs"
export default class extends Controller {
  static classes = ['active'];
  static targets = ['btn', 'tab', 'container', 'leftArrow', 'rightArrow'];
  static values = { defaultTab: String };

  connect() {
    if (this.hasLeftArrowTarget && this.hasRightArrowTarget)
      this.updateArrows();

    if (this.hasContainerTarget)
      this.containerTarget.addEventListener(
        'scroll',
        this.updateArrows.bind(this)
      );

    this.selectInitialTab();
  }

  selectInitialTab() {
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

      this.scrollToTab(selectedBtn);
    }
  }

  scrollLeft() {
    const scrollAmount = this.containerTarget.offsetWidth * 0.3;
    this.containerTarget.scrollBy({ left: -scrollAmount, behavior: 'smooth' });
  }

  scrollRight() {
    const scrollAmount = this.containerTarget.offsetWidth * 0.3;
    this.containerTarget.scrollBy({ left: scrollAmount, behavior: 'smooth' });
  }

  updateArrows() {
    const { scrollLeft, scrollWidth, clientWidth } = this.containerTarget;

    if (scrollLeft <= 10) {
      this.hideLeftArrow();
    } else {
      this.showLeftArrow();
    }

    if (scrollLeft + clientWidth >= scrollWidth - 10) {
      this.hideRightArrow();
    } else {
      this.showRightArrow();
    }

    if (scrollLeft > 10 && scrollLeft + clientWidth < scrollWidth - 10) {
      this.showLeftArrow();
      this.showRightArrow();
    }
  }

  hideLeftArrow() {
    this.leftArrowTarget.classList.add('opacity-0');
  }

  showLeftArrow() {
    this.leftArrowTarget.classList.remove('opacity-0');
  }

  hideRightArrow() {
    this.rightArrowTarget.classList.add('opacity-0');
  }

  showRightArrow() {
    this.rightArrowTarget.classList.remove('opacity-0');
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
    if (!this.hasContainerTarget || !tab) return;

    const container = this.containerTarget;

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
