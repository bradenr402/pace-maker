import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="confirmation"
export default class extends Controller {
  static values = { message: String };

  confirm(event) {
    if (!window.confirm(this.messageValue)) {
      event.preventDefault();
      event.stopImmediatePropagation();
    }
  }
}
