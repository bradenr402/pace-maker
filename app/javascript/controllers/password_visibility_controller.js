import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="password-visibility"
export default class extends Controller {
  static targets = ['password', 'visibleIcon', 'hiddenIcon'];

  toggle() {
    if (this.passwordTarget.type === 'password') {
      this.passwordTarget.type = 'text';
      this.visibleIconTarget.classList.add('hidden');
      this.hiddenIconTarget.classList.remove('hidden');
    } else {
      this.passwordTarget.type = 'password';
      this.visibleIconTarget.classList.remove('hidden');
      this.hiddenIconTarget.classList.add('hidden');
    }
  }
}
