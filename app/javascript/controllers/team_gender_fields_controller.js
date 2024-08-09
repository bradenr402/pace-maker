import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="team-gender-fields"
export default class extends Controller {
  static targets = [
    'requireGender',
    'longRunMale',
    'longRunFemale',
    'longRunNeutral',
  ];

  toggleFields() {
    if (this.requireGenderTarget.checked) {
      this.genderRequired();
    } else {
      this.genderNotRequired();
    }
  }

  genderRequired() {
    this.longRunMaleTarget.classList.remove('hidden');
    this.longRunFemaleTarget.classList.remove('hidden');
    this.longRunNeutralTarget.classList.add('hidden');
  }

  genderNotRequired() {
    this.longRunMaleTarget.classList.add('hidden');
    this.longRunFemaleTarget.classList.add('hidden');
    this.longRunNeutralTarget.classList.remove('hidden');
  }
}
