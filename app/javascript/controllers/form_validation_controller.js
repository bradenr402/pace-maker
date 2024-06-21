import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="form-validation"
export default class extends Controller {
  static targets = [
    'email',
    'username',
    'login',
    'password',
    'passwordConfirmation',
    'newPassword',
    'newPasswordConfirmation',
    'currentPassword',
    'date',
    'distance',
    'duration',
    'comments',
    'passwordLength',
    'passwordUppercase',
    'passwordLowercase',
    'passwordDigit',
    'passwordSpecial',
    'passwordRequirements',
    'passwordConfirmationError',
    'newPasswordConfirmationError',
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
      this.showError(this.emailTarget, 'Invalid email address');
    } else {
      this.clearError(this.emailTarget);
    }
  }

  validateUsername(event) {
    const username = this.usernameTarget.value;
    const usernameRegex = /^[a-z0-9_.]{3,}$/;
    if (!usernameRegex.test(username)) {
      this.showError(
        this.usernameTarget,
        'Username can only contain lowercase letters, numbers, underscores, and periods and must be at least 3 characters long'
      );
    } else {
      this.clearError(this.usernameTarget);
    }
  }

  validateLogin(event) {
    const input = this.loginTarget.value;
    const usernameRegex = /^[a-z0-9_.]{3,}$/;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!usernameRegex.test(input) && !emailRegex.test(input)) {
      this.showError(this.loginTarget, 'Must be a valid email or username');
    } else {
      this.clearError(this.loginTarget);
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
    this.validatePasswordLength(password);
    this.validatePasswordUppercase(password);
    this.validatePasswordLowercase(password);
    this.validatePasswordDigit(password);
    this.validatePasswordSpecial(password);
  }

  validatePasswordLength(password) {
    this.passwordLengthTarget.classList.remove('help-text');
    if (password.length >= 6) {
      this.passwordLengthTarget.classList.remove('error-message');
      this.passwordLengthTarget.classList.add('valid-message');
      this.lengthCheckTarget.classList.remove('hidden');
      this.lengthCrossTarget.classList.add('hidden');
    } else {
      this.passwordLengthTarget.classList.add('error-message');
      this.passwordLengthTarget.classList.remove('valid-message');
      this.lengthCheckTarget.classList.add('hidden');
      this.lengthCrossTarget.classList.remove('hidden');
    }
  }

  validatePasswordUppercase(password) {
    this.passwordUppercaseTarget.classList.remove('help-text');
    if (/[A-Z]/.test(password)) {
      this.passwordUppercaseTarget.classList.remove('error-message');
      this.passwordUppercaseTarget.classList.add('valid-message');
      this.uppercaseCheckTarget.classList.remove('hidden');
      this.uppercaseCrossTarget.classList.add('hidden');
    } else {
      this.passwordUppercaseTarget.classList.add('error-message');
      this.passwordUppercaseTarget.classList.remove('valid-message');
      this.uppercaseCheckTarget.classList.add('hidden');
      this.uppercaseCrossTarget.classList.remove('hidden');
    }
  }

  validatePasswordLowercase(password) {
    this.passwordLowercaseTarget.classList.remove('help-text');
    if (/[a-z]/.test(password)) {
      this.passwordLowercaseTarget.classList.remove('error-message');
      this.passwordLowercaseTarget.classList.add('valid-message');
      this.lowercaseCheckTarget.classList.remove('hidden');
      this.lowercaseCrossTarget.classList.add('hidden');
    } else {
      this.passwordLowercaseTarget.classList.add('error-message');
      this.passwordLowercaseTarget.classList.remove('valid-message');
      this.lowercaseCheckTarget.classList.add('hidden');
      this.lowercaseCrossTarget.classList.remove('hidden');
    }
  }

  validatePasswordDigit(password) {
    this.passwordDigitTarget.classList.remove('help-text');
    if (/\d/.test(password)) {
      this.passwordDigitTarget.classList.remove('error-message');
      this.passwordDigitTarget.classList.add('valid-message');
      this.digitCheckTarget.classList.remove('hidden');
      this.digitCrossTarget.classList.add('hidden');
    } else {
      this.passwordDigitTarget.classList.add('error-message');
      this.passwordDigitTarget.classList.remove('valid-message');
      this.digitCheckTarget.classList.add('hidden');
      this.digitCrossTarget.classList.remove('hidden');
    }
  }

  validatePasswordSpecial(password) {
    this.passwordSpecialTarget.classList.remove('help-text');
    if (/[#?!@$%^&*-]/.test(password)) {
      this.passwordSpecialTarget.classList.remove('error-message');
      this.passwordSpecialTarget.classList.add('valid-message');
      this.specialCheckTarget.classList.remove('hidden');
      this.specialCrossTarget.classList.add('hidden');
    } else {
      this.passwordSpecialTarget.classList.add('error-message');
      this.passwordSpecialTarget.classList.remove('valid-message');
      this.specialCheckTarget.classList.add('hidden');
      this.specialCrossTarget.classList.remove('hidden');
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
      this.validatePasswordLength(newPassword);
      this.validatePasswordUppercase(newPassword);
      this.validatePasswordLowercase(newPassword);
      this.validatePasswordDigit(newPassword);
      this.validatePasswordSpecial(newPassword);
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
      this.showError(this.dateTarget, 'Date must be today or earlier');
    } else {
      this.clearError(this.dateTarget);
    }
  }

  validateDistance(event) {
    const distance = parseFloat(this.distanceTarget.value);
    if (isNaN(distance) || distance < 0) {
      this.showError(this.distanceTarget, 'Distance must be a positive number');
    } else {
      this.clearError(this.distanceTarget);
    }
  }

  validateDuration(event) {
    const time = this.durationTarget.value;
    const durationRegex = /^((2[0-3]|1\d|0?\d):)?([0-5]?\d):([0-5]\d)$/;
    if (!durationRegex.test(time)) {
      this.showError(
        this.durationTarget,
        'Duration must be in MM:SS or HH:MM:SS format and must be less than 24 hours'
      );
    } else {
      this.clearError(this.durationTarget);
    }
  }

  showError(element, message) {
    let errorElement = element.nextElementSibling;
    if (!errorElement || !errorElement.classList.contains('error-message')) {
      errorElement = document.createElement('span');
      errorElement.classList.add('error-message');
      element.after(errorElement);
    }
    errorElement.textContent = message;
    errorElement.classList.remove('hidden');
    element.classList.add('form-input-error');
  }

  clearError(element) {
    const errorElement = element.nextElementSibling;
    if (errorElement && errorElement.classList.contains('error-message')) {
      errorElement.classList.add('hidden');
    }
    element.classList.remove('form-input-error');
  }
}
