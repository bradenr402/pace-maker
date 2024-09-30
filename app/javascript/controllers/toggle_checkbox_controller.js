import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-checkbox"
export default class extends Controller {
  static targets = ['checkbox']

  toggle() {
    this.checkboxTarget.checked = !this.checkboxTarget.checked;
    this.checkboxTarget.dispatchEvent(new Event('change'));
  }
}
