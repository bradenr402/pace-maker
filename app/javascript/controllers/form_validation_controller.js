import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="form-validation"
export default class extends Controller {
  static targets = [
    'email',
    'emailError',
    'username',
    'usernameError',
    'login',
    'loginError',
    'password',
    'passwordConfirmation',
    'passwordConfirmationError',
    'newPassword',
    'newPasswordConfirmation',
    'newPasswordConfirmationError',
    'currentPassword',
    'date',
    'dateError',
    'distance',
    'distanceError',
    'duration',
    'durationError',
    'teamName',
    'teamNameError',
    'teamDescription',
    'teamDescriptionError',
    'seasonStartDate',
    'seasonEndDate',
    'seasonEndDateError',
    'milageGoal',
    'milageGoalError',
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
  ];

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
    if (
      lengthValid &&
      uppercaseValid &&
      lowercaseValid &&
      digitValid &&
      specialValid
    ) {
      this.passwordTarget.classList.remove('form-input-error');
    } else {
      this.passwordTarget.classList.add('form-input-error');
    }
  }

  validatePasswordLength(password) {
    this.passwordLengthTarget.classList.remove('help-text');
    if (password.length >= 6) {
      this.passwordLengthTarget.classList.remove('error-message');
      this.passwordLengthTarget.classList.add('valid-message');
      this.lengthCheckTarget.classList.remove('hidden');
      this.lengthCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordLengthTarget.classList.add('error-message');
      this.passwordLengthTarget.classList.remove('valid-message');
      this.lengthCheckTarget.classList.add('hidden');
      this.lengthCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordUppercase(password) {
    this.passwordUppercaseTarget.classList.remove('help-text');
    if (/[A-Z]/.test(password)) {
      this.passwordUppercaseTarget.classList.remove('error-message');
      this.passwordUppercaseTarget.classList.add('valid-message');
      this.uppercaseCheckTarget.classList.remove('hidden');
      this.uppercaseCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordUppercaseTarget.classList.add('error-message');
      this.passwordUppercaseTarget.classList.remove('valid-message');
      this.uppercaseCheckTarget.classList.add('hidden');
      this.uppercaseCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordLowercase(password) {
    this.passwordLowercaseTarget.classList.remove('help-text');
    if (/[a-z]/.test(password)) {
      this.passwordLowercaseTarget.classList.remove('error-message');
      this.passwordLowercaseTarget.classList.add('valid-message');
      this.lowercaseCheckTarget.classList.remove('hidden');
      this.lowercaseCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordLowercaseTarget.classList.add('error-message');
      this.passwordLowercaseTarget.classList.remove('valid-message');
      this.lowercaseCheckTarget.classList.add('hidden');
      this.lowercaseCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordDigit(password) {
    this.passwordDigitTarget.classList.remove('help-text');
    if (/\d/.test(password)) {
      this.passwordDigitTarget.classList.remove('error-message');
      this.passwordDigitTarget.classList.add('valid-message');
      this.digitCheckTarget.classList.remove('hidden');
      this.digitCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordDigitTarget.classList.add('error-message');
      this.passwordDigitTarget.classList.remove('valid-message');
      this.digitCheckTarget.classList.add('hidden');
      this.digitCrossTarget.classList.remove('hidden');
      return false;
    }
  }

  validatePasswordSpecial(password) {
    this.passwordSpecialTarget.classList.remove('help-text');
    if (/[#?!@$%^&*-]/.test(password)) {
      this.passwordSpecialTarget.classList.remove('error-message');
      this.passwordSpecialTarget.classList.add('valid-message');
      this.specialCheckTarget.classList.remove('hidden');
      this.specialCrossTarget.classList.add('hidden');
      return true;
    } else {
      this.passwordSpecialTarget.classList.add('error-message');
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

      if (
        lengthValid &&
        uppercaseValid &&
        lowercaseValid &&
        digitValid &&
        specialValid
      ) {
        this.newPasswordTarget.classList.remove('form-input-error');
      } else {
        this.newPasswordTarget.classList.add('form-input-error');
      }
    } else {
      this.hidePasswordRequirements();
    }
  }

  validateNewPasswordConfirmation(event) {
    const newPassword = this.newPasswordTarget.value;
    const newPasswordConfirmation = this.newPasswordConfirmationTarget.value;
    if (
      newPassword &&
      newPassword !== newPasswordConfirmation &&
      event.target !== this.newPasswordTarget
    ) {
      this.newPasswordConfirmationErrorTarget.classList.remove('hidden');
    } else {
      this.newPasswordConfirmationErrorTarget.classList.add('hidden');
    }
  }

  validateDate(event) {
    const date = this.dateTarget.value;
    if (!(Date.parse(date) <= new Date())) {
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

  validateDuration(event) {
    const time = this.durationTarget.value;
    const durationRegex = /^((2[0-3]|1\d|0?\d):)?([0-5]?\d):([0-5]\d)$/;
    if (!durationRegex.test(time)) {
      this.durationTarget.classList.add('form-input-error');
      this.durationErrorTarget.classList.remove('hidden');
    } else {
      this.durationTarget.classList.remove('form-input-error');
      this.durationErrorTarget.classList.add('hidden');
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
    } else {
      this.teamDescriptionTarget.classList.remove('form-input-error');
      this.teamDescriptionErrorTarget.classList.add('hidden');
    }
  }

  validateSeasonEndDate(event) {
    const startDate = this.seasonStartDateTarget.value;
    const endDate = this.seasonEndDateTarget.value;
    if (startDate) {
      if (Date.parse(startDate) >= Date.parse(endDate)) {
        this.seasonEndDateTarget.classList.add('form-input-error');
        this.seasonEndDateErrorTarget.classList.remove('hidden');
      } else {
        this.seasonEndDateTarget.classList.remove('form-input-error');
        this.seasonEndDateErrorTarget.classList.add('hidden');
      }
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
}
