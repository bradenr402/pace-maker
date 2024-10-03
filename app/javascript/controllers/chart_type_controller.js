import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="chart-type"
export default class extends Controller {
  static classes = ['active'];
  static targets = ['btn', 'tab', 'container', 'indicator'];
  static values = { defaultTab: String };

  connect() {
    this._selectInitialTab();
  }

  select(event) {
    const selectedTabId = event.currentTarget.id;
    const selectedBtn = this.btnTargets.find((btn) => btn.id === selectedTabId);

    this._updateTabVisibility(selectedTabId);
    this._updateTabIndicator(selectedBtn);
  }

  _selectInitialTab() {
    const intialTabId = this.defaultTabValue;
    this._updateTabVisibility(intialTabId);

    const selectedBtn = this.btnTargets.find((btn) => btn.id === intialTabId);
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
}
