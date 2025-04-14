import { Controller } from '@hotwired/stimulus';
import 'chartkick';

// Connects to data-controller="tabs"
export default class extends Controller {
  static classes = ['active'];
  static targets = ['btn', 'tab', 'container', 'leftArrow', 'rightArrow', 'indicator'];
  static values = {
    defaultTab: String,
    tabUrl: String,
    scrollFraction: { type: Number, default: 0.8 },
  };

  connect() {
    this.preloadTimeouts = {};

    if (this.hasLeftArrowTarget && this.hasRightArrowTarget) this._updateArrows();

    if (this.hasContainerTarget)
      this.containerTarget.addEventListener(
        'scroll',
        this._debounce(this._updateArrows.bind(this)),
      );

    this._selectInitialTab();
    this._preloadTabs();
  }

  scrollLeft() {
    const scrollAmount = this.containerTarget.offsetWidth * this.scrollFractionValue;
    this.containerTarget.scrollBy({ left: -scrollAmount, behavior: 'smooth' });
  }

  scrollRight() {
    const scrollAmount = this.containerTarget.offsetWidth * this.scrollFractionValue;
    this.containerTarget.scrollBy({ left: scrollAmount, behavior: 'smooth' });
  }

  select(event) {
    const selectedTabId = event.currentTarget.id;
    const selectedTab = this.tabTargets.find((tab) => tab.id === selectedTabId);

    // Cancel any pending preload for this tab
    if (this.preloadTimeouts[selectedTabId]) {
      clearTimeout(this.preloadTimeouts[selectedTabId]);
      delete this.preloadTimeouts[selectedTabId];
    }

    if (selectedTab?.hidden) {
      this._updateTabVisibility(selectedTabId);
      this._updateUrlWithTab(selectedTabId);
      this._scrollToTab(event.currentTarget);
      this._loadTabContent(selectedTabId);
    }

    this._updateTabIndicator(event.currentTarget);
  }

  _loadTabContent(tabId) {
    if (!this.tabUrlValue) return;
    if (!this.tabTargets) return;

    const tabElement = this.tabTargets.find((tab) => tab.id === tabId);
    if (!tabElement || tabElement.dataset.loaded === 'true') return;

    const url = this.tabUrlValue.replace('%3Atab_id', tabId);

    fetch(url)
      .then((response) => {
        if (!response.ok) throw new Error('Network error');
        return response.text();
      })
      .then((html) => {
        if (!html) throw new Error('Empty response body');

        tabElement.innerHTML = html;
        tabElement.dataset.loaded = 'true';

        this._rerunScripts(tabElement); // Reinitialize Chartkick charts
      })
      .catch((error) => {
        console.error('Error loading tab content:', error);
        tabElement.innerHTML = `
          <div class="flex flex-col items-center justify-center gap-4 mt-16 text-rose-600 dark:text-rose-400">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="size-14"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
              />
            </svg>


            <p class="text-center font-semibold">Failed to load tab content. Please try reloading the page.</p>
          </div>
        `;
      });
  }

  _preloadTabs() {
    const initialTab = this._initialTabValue();

    this.tabTargets.forEach((tab, index) => {
      if (tab.id !== initialTab && !tab.dataset.loaded) {
        const timeoutId = setTimeout(() => {
          this._loadTabContent(tab.id);
          delete this.preloadTimeouts[tab.id];
        }, 2000 + index * 1000);

        this.preloadTimeouts[tab.id] = timeoutId;
      }
    });
  }

  _rerunScripts(element) {
    element.querySelectorAll('script').forEach((script) => {
      const newScript = document.createElement('script');

      if (script.src) {
        newScript.src = script.src;
        newScript.async = false;
      } else {
        newScript.textContent = script.textContent;
      }
      script.replaceWith(newScript);
    });
  }

  _initialTabValue() {
    // Get the initial tab from the URL tab parameter
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');

    return tabParam || this.defaultTabValue;
  }

  _selectInitialTab() {
    const initialTab = this._initialTabValue();

    this._loadTabContent(initialTab);

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

  _hideLeftArrow = () => this.leftArrowTarget.classList.add('opacity-0', 'pointer-events-none');

  _showLeftArrow = () => this.leftArrowTarget.classList.remove('opacity-0', 'pointer-events-none');

  _hideRightArrow = () => this.rightArrowTarget.classList.add('opacity-0', 'pointer-events-none');

  _showRightArrow = () =>
    this.rightArrowTarget.classList.remove('opacity-0', 'pointer-events-none');

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
