import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="filter-gender"
export default class extends Controller {
  static targets = ['filter', 'genderCell', 'row'];

  filter() {
    const selectedGender = this.filterTarget.value;

    this.rowTargets.forEach((row) => {
      const genderCell = row.querySelector(
        "[data-filter-gender-target='genderCell']"
      );

      if (genderCell) {
        const gender = genderCell.textContent.trim();
        if (selectedGender === 'all' || gender.toLowerCase() === selectedGender)
          row.classList.remove('hidden');
        else row.classList.add('hidden');
      }
    });
  }
}
