import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="form-validation"
export default class extends Controller {
  static targets = [
    'email',
    'emailError',
    'phone',
    'phoneError',
    'displayName',
    'displayNameError',
    'username',
    'usernameError',
    'login',
    'loginError',
    'password',
    'passwordConfirmation',
    'passwordConfirmationError',
    'newPassword',
    'newPasswordConfirmation',
    'newPasswordConfirmationHint',
    'newPasswordConfirmationLabel',
    'newPasswordConfirmationError',
    'currentPassword',
    'date',
    'dateError',
    'distance',
    'distanceError',
    'teamName',
    'teamNameError',
    'teamDescription',
    'teamDescriptionError',
    'seasonStartDate',
    'seasonEndDate',
    'seasonEndDateLabel',
    'seasonEndDateError',
    'mileageGoal',
    'mileageGoalError',
    'longRunGoal',
    'longRunGoalError',
    'passwordLength',
    'passwordUppercase',
    'passwordLowercase',
    'passwordDigit',
    'passwordSpecial',
    'passwordRequirements',
    'lengthCheck',
    'lengthCross',
    'uppercaseCheck',
    'uppercaseCross',
    'lowercaseCheck',
    'lowercaseCross',
    'digitCheck',
    'digitCross',
    'specialCheck',
    'specialCross',
    'startDate',
    'endDate',
    'endDateError',
    'eventTitle',
    'eventTitleError',
    'eventDescription',
    'eventDescriptionError',
    'eventStartDate',
    'eventEndDate',
    'eventEndDateError',
    'link',
    'linkError',
  ];

  connect() {
    if (this.hasSeasonEndDateTarget) {
      if (this.seasonStartDateTarget.value) {
        this.seasonEndDateTarget.disabled = false;
        this.seasonEndDateLabelTarget.classList.remove('opacity-60');
      } else {
        this.seasonEndDateTarget.disabled = true;
        this.seasonEndDateLabelTarget.classList.add('opacity-60');
      }
    }

    if (this.hasNewPasswordConfirmationTarget) {
      if (this.newPasswordTarget.value) {
        this.newPasswordConfirmationTarget.disabled = false;
        this.newPasswordConfirmationLabelTarget.classList.remove('opacity-60');
        this.newPasswordConfirmationHintTarget.classList.remove('opacity-0', 'pointer-events-none');
      } else {
        this.newPasswordConfirmationTarget.disabled = true;
        this.newPasswordConfirmationLabelTarget.classList.add('opacity-60');
        this.newPasswordConfirmationHintTarget.classList.add('opacity-0', 'pointer-events-none');
      }
    }
  }

  validateEmail(event) {
    const email = this.emailTarget.value;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      this.emailTarget.classList.add('form-input-error');
      this.emailErrorTarget.classList.remove('hidden');
    } else {
      this.emailTarget.classList.remove('form-input-error');
      this.emailErrorTarget.classList.add('hidden');
    }
  }

  validatePhone(event) {
    const phone = this.phoneTarget.value.trim();
    const phoneRegex = /^\+?[\d\s\-\(\)]{10,15}$/;

    if (phone && !phoneRegex.test(phone)) {
      this.phoneTarget.classList.add('form-input-error');
      this.phoneErrorTarget.classList.remove('hidden');
    } else {
      this.phoneTarget.classList.remove('form-input-error');
      this.phoneErrorTarget.classList.add('hidden');
    }
  }

  validateDisplayName(event) {
    const displayName = this.displayNameTarget.value;
    if (displayName.length > 100) {
      this.displayNameTarget.classList.add('form-input-error');
      this.displayNameErrorTarget.classList.remove('hidden');
    } else {
      this.displayNameTarget.classList.remove('form-input-error');
      this.displayNameErrorTarget.classList.add('hidden');
    }
  }

  validateUsername(event) {
    const username = this.usernameTarget.value;
    const usernameRegex = /^[a-z0-9_.]{3,}$/;
    if (!usernameRegex.test(username)) {
      this.usernameTarget.classList.add('form-input-error');
      this.usernameErrorTarget.classList.remove('hidden');
    } else {
      this.usernameTarget.classList.remove('form-input-error');
      this.usernameErrorTarget.classList.add('hidden');
    }
  }

  validateLogin(event) {
    const input = this.loginTarget.value;
    const usernameRegex = /^[a-z0-9_.]{3,}$/;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!usernameRegex.test(input) && !emailRegex.test(input)) {
      this.loginTarget.classList.add('form-input-error');
      this.loginErrorTarget.classList.remove('hidden');
    } else {
      this.loginTarget.classList.remove('form-input-error');
      this.loginErrorTarget.classList.add('hidden');
    }
  }

  showPasswordRequirements() {
    this.passwordRequirementsTarget.classList.remove('hidden');
  }

  hidePasswordRequirements() {
    this.passwordRequirementsTarget.classList.add('hidden');
  }

  validatePassword(event) {
    const password = this.passwordTarget.value;
    const lengthValid = this.validatePasswordLength(password);
    const uppercaseValid = this.validatePasswordUppercase(password);
    const lowercaseValid = this.validatePasswordLowercase(password);
    const digitValid = this.validatePasswordDigit(password);
    const specialValid = this.validatePasswordSpecial(password);

    if (lengthValid && uppercaseValid && lowercaseValid && digitValid && specialValid) {
      this.passwordTarget.classList.remove('form-input-error');
    } else {
      this.passwordTarget.classList.add('form-input-error');
    }
  }

  validatePasswordLength(password) {
    this.passwordLengthTarget.classList.remove('help-text');
    if (password.length >= 6) {
      this.passwordLengthTarget.classList.remove('help-text');
      this.passwordLengthTarget.classList.add('valid-message');
      this.lengthCheckTarget.classList.remove('hidden');
      this.lengthCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordLengthTarget.classList.add('help-text');
      this.passwordLengthTarget.classList.remove('valid-message');
      this.lengthCheckTarget.classList.add('hidden');
      this.lengthCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordUppercase(password) {
    this.passwordUppercaseTarget.classList.remove('help-text');
    if (/[A-Z]/.test(password)) {
      this.passwordUppercaseTarget.classList.remove('help-text');
      this.passwordUppercaseTarget.classList.add('valid-message');
      this.uppercaseCheckTarget.classList.remove('hidden');
      this.uppercaseCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordUppercaseTarget.classList.add('help-text');
      this.passwordUppercaseTarget.classList.remove('valid-message');
      this.uppercaseCheckTarget.classList.add('hidden');
      this.uppercaseCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordLowercase(password) {
    this.passwordLowercaseTarget.classList.remove('help-text');
    if (/[a-z]/.test(password)) {
      this.passwordLowercaseTarget.classList.remove('help-text');
      this.passwordLowercaseTarget.classList.add('valid-message');
      this.lowercaseCheckTarget.classList.remove('hidden');
      this.lowercaseCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordLowercaseTarget.classList.add('help-text');
      this.passwordLowercaseTarget.classList.remove('valid-message');
      this.lowercaseCheckTarget.classList.add('hidden');
      this.lowercaseCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordDigit(password) {
    this.passwordDigitTarget.classList.remove('help-text');
    if (/\d/.test(password)) {
      this.passwordDigitTarget.classList.remove('help-text');
      this.passwordDigitTarget.classList.add('valid-message');
      this.digitCheckTarget.classList.remove('hidden');
      this.digitCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordDigitTarget.classList.add('help-text');
      this.passwordDigitTarget.classList.remove('valid-message');
      this.digitCheckTarget.classList.add('hidden');
      this.digitCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordSpecial(password) {
    this.passwordSpecialTarget.classList.remove('help-text');
    if (/[#?!@$%^&*-]/.test(password)) {
      this.passwordSpecialTarget.classList.remove('help-text');
      this.passwordSpecialTarget.classList.add('valid-message');
      this.specialCheckTarget.classList.remove('hidden');
      this.specialCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordSpecialTarget.classList.add('help-text');
      this.passwordSpecialTarget.classList.remove('valid-message');
      this.specialCheckTarget.classList.add('hidden');
      this.specialCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordConfirmation(event) {
    const password = this.passwordTarget.value;
    const passwordConfirmation = this.passwordConfirmationTarget.value;
    if (password !== passwordConfirmation) {
      this.passwordConfirmationErrorTarget.classList.remove('hidden');
    } else {
      this.passwordConfirmationErrorTarget.classList.add('hidden');
    }
  }

  validateNewPassword(event) {
    const newPassword = this.newPasswordTarget.value;
    if (newPassword) {
      this.showPasswordRequirements();
      const lengthValid = this.validatePasswordLength(newPassword);
      const uppercaseValid = this.validatePasswordUppercase(newPassword);
      const lowercaseValid = this.validatePasswordLowercase(newPassword);
      const digitValid = this.validatePasswordDigit(newPassword);
      const specialValid = this.validatePasswordSpecial(newPassword);

      if (lengthValid && uppercaseValid && lowercaseValid && digitValid && specialValid) {
        this.newPasswordTarget.classList.remove('form-input-error');
      } else {
        this.newPasswordTarget.classList.add('form-input-error');
      }
    } else {
      this.hidePasswordRequirements();
      this.newPasswordTarget.classList.remove('form-input-error');
    }
  }

  validateNewPasswordConfirmation(event) {
    const newPassword = this.newPasswordTarget.value;
    const newPasswordConfirmation = this.newPasswordConfirmationTarget.value;

    if (newPassword) {
      this.newPasswordConfirmationTarget.disabled = false;
      this.newPasswordConfirmationLabelTarget.classList.remove('opacity-60');
      this.newPasswordConfirmationHintTarget.classList.remove('opacity-0', 'pointer-events-none');

      if (newPassword !== newPasswordConfirmation && event.target !== this.newPasswordTarget) {
        this.newPasswordConfirmationErrorTarget.classList.remove('hidden');
      } else {
        this.newPasswordConfirmationErrorTarget.classList.add('hidden');
      }
    } else {
      this.newPasswordConfirmationTarget.disabled = true;
      this.newPasswordConfirmationLabelTarget.classList.add('opacity-60');
      this.newPasswordConfirmationHintTarget.classList.add('opacity-0', 'pointer-events-none');
      this.newPasswordConfirmationErrorTarget.classList.add('hidden');
    }
  }

  validateDate(event) {
    const date = Date.parse(this.dateTarget.value);
    const today = new Date();

    if (date >= today) {
      this.dateTarget.classList.add('form-input-error');
      this.dateErrorTarget.classList.remove('hidden');
    } else {
      this.dateTarget.classList.remove('form-input-error');
      this.dateErrorTarget.classList.add('hidden');
    }
  }

  validateDistance(event) {
    const distance = parseFloat(this.distanceTarget.value);
    if (isNaN(distance) || distance < 0) {
      this.distanceTarget.classList.add('form-input-error');
      this.distanceErrorTarget.classList.remove('hidden');
    } else {
      this.distanceTarget.classList.remove('form-input-error');
      this.distanceErrorTarget.classList.add('hidden');
    }
  }

  validateTeamName(event) {
    const name = this.teamNameTarget.value;
    if (!name) {
      this.teamNameTarget.classList.add('form-input-error');
      this.teamNameErrorTarget.classList.remove('hidden');
    } else {
      this.teamNameTarget.classList.remove('form-input-error');
      this.teamNameErrorTarget.classList.add('hidden');
    }
  }

  validateTeamDescription(event) {
    const description = this.teamDescriptionTarget.value;
    if (description.length > 500) {
      this.teamDescriptionTarget.classList.add('form-input-error');
      this.teamDescriptionErrorTarget.classList.remove('hidden');

      this.teamDescriptionTarget.value = description.slice(0, 500);
      this.teamDescriptionTarget.dispatchEvent(new Event('change', { bubbles: true }));
    } else {
      this.teamDescriptionTarget.classList.remove('form-input-error');
      this.teamDescriptionErrorTarget.classList.add('hidden');
    }
  }

  validateSeasonEndDate(event) {
    const startDate = Date.parse(this.seasonStartDateTarget.value);
    const endDate = Date.parse(this.seasonEndDateTarget.value);

    if (!startDate) {
      this.seasonEndDateTarget.disabled = true;
      this.seasonEndDateLabelTarget.classList.add('opacity-60');
      return;
    } else {
      this.seasonEndDateTarget.disabled = false;
      this.seasonEndDateLabelTarget.classList.remove('opacity-60');
    }

    if (startDate >= endDate) {
      this.seasonEndDateTarget.classList.add('form-input-error');
      this.seasonEndDateErrorTarget.classList.remove('hidden');
    } else {
      this.seasonEndDateTarget.classList.remove('form-input-error');
      this.seasonEndDateErrorTarget.classList.add('hidden');
    }
  }

  validateMileageGoal(event) {
    const mileageGoal = this.mileageGoalTarget.value;
    if (mileageGoal) {
      if (isNaN(mileageGoal) || mileageGoal < 0) {
        this.mileageGoalTarget.classList.add('form-input-error');
        this.mileageGoalErrorTarget.classList.remove('hidden');
      } else {
        this.mileageGoalTarget.classList.remove('form-input-error');
        this.mileageGoalErrorTarget.classList.add('hidden');
      }
    }
  }

  validateLongRunGoal(event) {
    const longRunGoal = this.longRunGoalTarget.value;
    if (longRunGoal) {
      if (isNaN(longRunGoal) || longRunGoal < 0) {
        this.longRunGoalTarget.classList.add('form-input-error');
        this.longRunGoalErrorTarget.classList.remove('hidden');
      } else {
        this.longRunGoalTarget.classList.remove('form-input-error');
        this.longRunGoalErrorTarget.classList.add('hidden');
      }
    }
  }

  validateEndDate(event) {
    const startDate = Date.parse(this.startDateTarget.value);
    const endDate = Date.parse(this.endDateTarget.value);
    const today = new Date();

    if (startDate >= endDate || endDate >= today) {
      this.endDateTarget.classList.add('form-input-error');
      this.endDateErrorTarget.classList.remove('hidden');
    } else {
      this.endDateTarget.classList.remove('form-input-error');
      this.endDateErrorTarget.classList.add('hidden');
    }
  }

  validateEventTitle(event) {
    const title = this.eventTitleTarget.value;
    if (!title) {
      this.eventTitleTarget.classList.add('form-input-error');
      this.eventTitleErrorTarget.classList.remove('hidden');
    } else {
      this.eventTitleTarget.classList.remove('form-input-error');
      this.eventTitleErrorTarget.classList.add('hidden');
    }
  }

  validateEventDescription(event) {
    const description = this.eventDescriptionTarget.value;
    if (description.length > 2000) {
      this.eventDescriptionTarget.classList.add('form-input-error');
      this.eventDescriptionErrorTarget.classList.remove('hidden');

      this.eventDescriptionTarget.value = description.slice(0, 2000);
      this.eventDescriptionTarget.dispatchEvent(new Event('change', { bubbles: true }));
    } else {
      this.eventDescriptionTarget.classList.remove('form-input-error');
      this.eventDescriptionErrorTarget.classList.add('hidden');
    }
  }

  validateEventStartDate(event) {
    const startDate = Date.parse(this.eventStartDateTarget.value);

    if (isNaN(startDate)) {
      this.eventStartDateTarget.classList.add('form-input-error');
      this.eventStartDateErrorTarget.classList.remove('hidden');
    } else {
      this.eventStartDateTarget.classList.remove('form-input-error');
      this.eventStartDateErrorTarget.classList.add('hidden');
    }
  }

  validateEventEndDate(event) {
    const startDate = Date.parse(this.eventStartDateTarget.value);
    const endDate = Date.parse(this.eventEndDateTarget.value);

    if (isNaN(startDate) || isNaN(endDate)) {
      this.eventEndDateTarget.classList.add('form-input-error');
      this.endDateErrorTarget.classList.remove('hidden');
    } else if (startDate > endDate) {
      this.eventEndDateTarget.classList.add('form-input-error');
      this.endDateErrorTarget.classList.remove('hidden');
    } else {
      this.eventEndDateTarget.classList.remove('form-input-error');
      this.endDateErrorTarget.classList.add('hidden');
    }
  }

  validateLink(event) {
    const link = this.linkTarget.value.trim();
    const linkRegex = /^(http|https):\/\/[^ "]+$/;
    const validPrefixes = [
      'h',
      'ht',
      'htt',
      'http',
      'http:',
      'http:/',
      'http://',
      'https',
      'https:',
      'https:/',
      'https://',
    ];

    if (event.type === 'input' && validPrefixes.includes(link)) {
      // Don't show the error message while the user is typing and hasn't finished typing a valid URL prefix
      this.linkTarget.classList.remove('form-input-error');
      this.linkErrorTarget.classList.add('hidden');
      return;
    }

    if (link && !linkRegex.test(link)) {
      this.linkTarget.classList.add('form-input-error');
      this.linkErrorTarget.classList.remove('hidden');
    } else {
      this.linkTarget.classList.remove('form-input-error');
      this.linkErrorTarget.classList.add('hidden');
    }
  }
}
