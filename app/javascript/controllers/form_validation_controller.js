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

  validatePassword(event) {
    const password = this.passwordTarget.value;
    if (password.length < 6) {
      this.showError(
        this.passwordTarget,
        'Password must be at least 6 characters long'
      );
    } else {
      this.clearError(this.passwordTarget);
    }
  }

  validatePasswordConfirmation(event) {
    const password = this.passwordTarget.value;
    const passwordConfirmation = this.passwordConfirmationTarget.value;
    if (password !== passwordConfirmation) {
      this.showError(this.passwordConfirmationTarget, 'Passwords do not match');
    } else {
      this.clearError(this.passwordConfirmationTarget);
    }
  }

  validateNewPassword(event) {
    const newPassword = this.newPasswordTarget.value;
    if (newPassword && newPassword.length < 6) {
      this.showError(
        this.newPasswordTarget,
        'Password must be at least 6 characters long'
      );
    } else {
      this.clearError(this.newPasswordTarget);
    }
  }

  validateNewPasswordConfirmation(event) {
    const newPassword = this.newPasswordTarget.value;
    const newPasswordConfirmation = this.newPasswordConfirmationTarget.value;
    if (newPassword && newPassword !== newPasswordConfirmation && event.target !== this.newPasswordTarget) {
      this.showError(this.newPasswordConfirmationTarget, 'Passwords do not match');
    } else {
      this.clearError(this.newPasswordConfirmationTarget);
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
    element.classList.add('form-input-error');
  }

  clearError(element) {
    const errorElement = element.nextElementSibling;
    if (errorElement && errorElement.classList.contains('error-message')) {
      errorElement.remove();
    }
    element.classList.remove('form-input-error');
  }
}
