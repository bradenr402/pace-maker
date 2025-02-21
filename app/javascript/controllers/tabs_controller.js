import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="tabs"
export default class extends Controller {
  static classes = ['active'];
  static targets = ['btn', 'tab', 'container', 'leftArrow', 'rightArrow', 'indicator'];
  static values = {
    defaultTab: String,
    scrollFraction: { type: Number, default: 0.8 },
  };

  connect() {
    if (this.hasLeftArrowTarget && this.hasRightArrowTarget)
      this._updateArrows();

    if (this.hasContainerTarget)
      this.containerTarget.addEventListener(
        'scroll',
        this._debounce(this._updateArrows.bind(this))
      );

    this._selectInitialTab();
  }

  scrollLeft() {
    const scrollAmount =
      this.containerTarget.offsetWidth * this.scrollFractionValue;
    this.containerTarget.scrollBy({ left: -scrollAmount, behavior: 'smooth' });
  }

  scrollRight() {
    const scrollAmount =
      this.containerTarget.offsetWidth * this.scrollFractionValue;
    this.containerTarget.scrollBy({ left: scrollAmount, behavior: 'smooth' });
  }

  select(event) {
    const selectedTabId = event.currentTarget.id;
    const selectedTab = this.tabTargets.find((tab) => tab.id === selectedTabId);

    if (selectedTab?.hidden) {
      this._updateTabVisibility(selectedTabId);
      this._updateUrlWithTab(selectedTabId);
      this._scrollToTab(event.currentTarget);
    }

    this._updateTabIndicator(event.currentTarget);
  }

  _selectInitialTab() {
    // Get the initial tab from the URL tab parameter
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');
    const initialTab = tabParam || this.defaultTabValue;

    this._updateTabVisibility(initialTab);

    const selectedBtn = this.btnTargets.find((btn) => btn.id === initialTab);
    this._scrollToTab(selectedBtn);
    this._updateTabIndicator(selectedBtn);
  }

  _updateTabIndicator(tab) {
    if (!this.hasIndicatorTarget || !tab) return;

    const indicator = this.indicatorTarget;
    indicator.style.left = `${tab.offsetLeft}px`;
    indicator.style.width = `${tab.offsetWidth}px`;
  }

  _updateTabVisibility(selectedTabId) {
    this.tabTargets.forEach((tab) => {
      const isSelected = tab.id === selectedTabId;
      tab.hidden = !isSelected;
      tab.classList.toggle('hidden', !isSelected);
    });

    this.btnTargets.forEach((btn) => {
      const isSelected = btn.id === selectedTabId;
      btn.classList.toggle(this.activeClass, isSelected);
    });
  }

  _scrollToTab(tab) {
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

  _updateArrows() {
    const { scrollLeft, scrollWidth, clientWidth } = this.containerTarget;

    if (scrollLeft <= 10) {
      this._hideLeftArrow();
    } else {
      this._showLeftArrow();
    }

    if (scrollLeft + clientWidth >= scrollWidth - 10) {
      this._hideRightArrow();
    } else {
      this._showRightArrow();
    }

    if (scrollLeft > 10 && scrollLeft + clientWidth < scrollWidth - 10) {
      this._showLeftArrow();
      this._showRightArrow();
    }
  }

  _hideLeftArrow() {
    this.leftArrowTarget.classList.add('opacity-0', 'pointer-events-none');
  }

  _showLeftArrow() {
    this.leftArrowTarget.classList.remove('opacity-0', 'pointer-events-none');
  }

  _hideRightArrow() {
    this.rightArrowTarget.classList.add('opacity-0', 'pointer-events-none');
  }

  _showRightArrow() {
    this.rightArrowTarget.classList.remove('opacity-0', 'pointer-events-none');
  }

  _updateUrlWithTab(tabId) {
    const url = new URL(window.location);
    url.searchParams.set('tab', tabId);
    window.history.replaceState({}, '', url);
  }

  _debounce(func, timeout = 50) {
    let timer;
    return (...args) => {
      clearTimeout(timer);
      timer = setTimeout(() => {
        func.apply(this, args);
      }, timeout);
    };
  }
}
