import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="form-submit"
export default class extends Controller {
  static targets = ['input', 'form'];

  submit(event) {
    event.preventDefault();
    this.formTarget.submit();
  }
}
