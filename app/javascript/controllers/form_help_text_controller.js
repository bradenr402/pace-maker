import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="form-help-text"
export default class extends Controller {
  static targets = ['input', 'output', 'plural'];

  update() {
    let inputValue = Math.round(this.inputTarget.value);
    if (inputValue) {
      this.inputTarget.value = inputValue;
      this.outputTarget.textContent = inputValue;

      if (inputValue == 1) {
        this.pluralTarget.classList.add('hidden');
        this.outputTarget.classList.add('hidden');
      } else {
        this.pluralTarget.classList.remove('hidden');
        this.outputTarget.classList.remove('hidden');
      }
    }
  }
}
