import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="autogrow"
export default class extends Controller {
  connect() {
    this.element.style.overflow = 'hidden';
    if (!this.element.closest('.hidden')) this.grow();
  }

  grow() {
    this.element.style.height = 'auto';
    this.element.style.height = `${this.element.scrollHeight}px`;
  }
}
