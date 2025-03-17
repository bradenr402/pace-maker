import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="filter-gender"
export default class extends Controller {
  static targets = [
    'radio',
    'genderCell',
    'row',
    'maleTotal',
    'femaleTotal',
    'unspecifiedTotal',
    'rankingsTable',
  ];

  getValue() {
    const selectedRadio = this.radioTargets.find((radio) => radio.checked);
    return selectedRadio ? selectedRadio.value : null;
  }

  filter() {
    const selectedGender = this.getValue();

    if (selectedGender === 'all') this.showAllTotals();
    else if (selectedGender === 'male') this.showMaleTotals();
    else if (selectedGender === 'female') this.showFemaleTotals();
    else if (selectedGender == 'unspecified') this.showUnspecifiedTotals();

    this.rowTargets.forEach((row) => {
      const genderCell = row.querySelector("[data-filter-gender-target='genderCell']");

      if (genderCell) {
        const gender = genderCell.dataset.gender;
        if (selectedGender === 'all' || gender.toLowerCase() === selectedGender)
          row.classList.remove('hidden');
        else row.classList.add('hidden');
      }
    });
  }

  showAllTotals() {
    if (this.hasMaleTotalTarget) this.maleTotalTarget.classList.remove('hidden');
    if (this.hasFemaleTotalTarget) this.femaleTotalTarget.classList.remove('hidden');
    if (this.hasUnspecifiedTotalTarget) this.unspecifiedTotalTarget.classList.remove('hidden');
  }

  showMaleTotals() {
    if (this.hasMaleTotalTarget) this.maleTotalTarget.classList.remove('hidden');
    if (this.hasFemaleTotalTarget) this.femaleTotalTarget.classList.add('hidden');
    if (this.hasUnspecifiedTotalTarget) this.unspecifiedTotalTarget.classList.add('hidden');
  }

  showFemaleTotals() {
    if (this.hasFemaleTotalTarget) this.femaleTotalTarget.classList.remove('hidden');
    if (this.hasMaleTotalTarget) this.maleTotalTarget.classList.add('hidden');
    if (this.hasUnspecifiedTotalTarget) this.unspecifiedTotalTarget.classList.add('hidden');
  }

  showUnspecifiedTotals() {
    if (this.hasUnspecifiedTotalTarget) this.unspecifiedTotalTarget.classList.remove('hidden');
    if (this.hasMaleTotalTarget) this.maleTotalTarget.classList.add('hidden');
    if (this.hasFemaleTotalTarget) this.femaleTotalTarget.classList.add('hidden');
  }

  rankingsTableTargetConnected() {
    if (this.hasRadioTarget) this.filter();
  }
}
