import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="custom-date-range"
export default class extends Controller {
  static targets = ['select', 'startDate', 'endDate'];

  update(event) {
    if (event.currentTarget.value === 'Custom range')
      this.showCustomRangeFields();
    else this.hideCustomRangeFields();
  }

  showCustomRangeFields() {
    this.startDateTarget.classList.remove('hidden');
    this.endDateTarget.classList.remove('hidden');
  }

  hideCustomRangeFields() {
    this.startDateTarget.classList.add('hidden');
    this.endDateTarget.classList.add('hidden');
  }
}
