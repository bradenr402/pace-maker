import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="filter-gender"
export default class extends Controller {
  static targets = [
    'filter',
    'genderCell',
    'row',
    'maleTotal',
    'femaleTotal',
    'rankingsTable',
  ];

  filter() {
    const selectedGender = this.filterTarget.value;

    if (selectedGender === 'all') {
      this.maleTotalTarget.classList.remove('hidden');
      this.femaleTotalTarget.classList.remove('hidden');
    } else if (selectedGender === 'male') {
      this.femaleTotalTarget.classList.add('hidden');
      this.maleTotalTarget.classList.remove('hidden');
    } else if (selectedGender === 'female') {
      this.femaleTotalTarget.classList.remove('hidden');
      this.maleTotalTarget.classList.add('hidden');
    }

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

  rankingsTableTargetConnected() {
    if (this.hasFilterTarget) this.filter();
  }
}
