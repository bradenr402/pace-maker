import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="team-gender-fields"
export default class extends Controller {
  static targets = [
    'requireGender',
    'longRunMale',
    'longRunFemale',
    'longRunNeutral',
    'streakMale',
    'streakFemale',
    'streakNeutral',
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

    this.streakMaleTarget.classList.remove('hidden');
    this.streakFemaleTarget.classList.remove('hidden');
    this.streakNeutralTarget.classList.add('hidden');
  }

  genderNotRequired() {
    this.longRunMaleTarget.classList.add('hidden');
    this.longRunFemaleTarget.classList.add('hidden');
    this.longRunNeutralTarget.classList.remove('hidden');

    this.streakMaleTarget.classList.add('hidden');
    this.streakFemaleTarget.classList.add('hidden');
    this.streakNeutralTarget.classList.remove('hidden');
  }
}
