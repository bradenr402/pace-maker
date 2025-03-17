import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="custom-date-range"
export default class extends Controller {
  static targets = ['radio', 'startDate', 'endDate', 'startDateField', 'endDateField'];

  connect() {
    this.timeout = null;
  }

  update() {
    clearTimeout(this.timeout);

    setTimeout(() => {
      const value = this.getValue();

      if (value === 'custom_range') this.showCustomRangeFields();
      else this.hideCustomRangeFields();
    }, 10);
  }

  showCustomRangeFields() {
    this.startDateTarget.classList.remove('hidden');
    this.endDateTarget.classList.remove('hidden');
  }

  hideCustomRangeFields() {
    this.startDateTarget.classList.add('hidden');
    this.endDateTarget.classList.add('hidden');
  }

  getValue() {
    const selectedRadio = this.radioTargets.find((radio) => radio.checked);
    return selectedRadio ? selectedRadio.value : null;
  }

  search() {
    const selectedValue = this.getValue();

    if (selectedValue !== 'custom_range') {
      this.element.requestSubmit();
      return;
    }

    if (!this.startDateFieldTarget.value || !this.endDateFieldTarget.value) return;

    const startDate = Date.parse(this.startDateFieldTarget.value);
    const endDate = Date.parse(this.endDateFieldTarget.value);

    if (isNaN(startDate) || isNaN(endDate)) return;

    const today = new Date();

    if (
      startDate > endDate ||
      endDate > today.getTime() ||
      endDate - startDate > 2 * 365 * 24 * 60 * 60 * 1000 // 2 years
    ) {
      return;
    }

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 300);
  }
}
