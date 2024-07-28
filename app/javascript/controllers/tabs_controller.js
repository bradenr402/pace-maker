import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="tabs"
export default class extends Controller {
  static classes = ['active'];
  static targets = ['btn', 'tab'];
  static values = { defaultTab: String };

  connect() {
    this.tabTargets.map((x) => {
      x.hidden = true;
      x.classList.add('hidden');
    });

    let selectedTab = this.tabTargets.find(
      (element) => element.id === this.defaultTabValue
    );
    selectedTab.hidden = false;
    selectedTab.classList.remove('hidden');

    let selectedBtn = this.btnTargets.find(
      (element) => element.id === this.defaultTabValue
    );
    selectedBtn.classList.add(...this.activeClasses);
  }

  select(event) {
    let selectedTab = this.tabTargets.find(
      (element) => element.id === event.currentTarget.id
    );
    if (selectedTab.hidden) {
      this.tabTargets.map((x) => {
        x.hidden = true;
        x.classList.add('hidden');
      });
      this.btnTargets.map((x) => x.classList.remove(...this.activeClasses));

      selectedTab.hidden = false;
      selectedTab.classList.remove('hidden');
      event.currentTarget.classList.add(...this.activeClasses);
    }
  }
}
