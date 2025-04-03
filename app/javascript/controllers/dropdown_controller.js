import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ['dropdown', 'arrowIcon'];
  static classes = ['hideDropdown', 'showDropdown', 'iconOpen', 'dropdownOpen'];

  connect() {
    this.closeOnOutsideClick = this._closeOnOutsideClick.bind(this);
    document.addEventListener('mousedown', this.closeOnOutsideClick);

    this.hide();
  }

  disconnect() {
    document.removeEventListener('mousedown', this.closeOnOutsideClick);
  }

  toggle(event) {
    event.preventDefault();

    if (this.dropdownTarget.classList.contains(...this.hideDropdownClasses)) this.show();
    else this.hide();
  }

  show() {
    this.dropdownTarget.classList.remove(...this.hideDropdownClasses);
    this.dropdownTarget.classList.add(...this.showDropdownClasses);
    this.dropdownTarget.classList.add(...this.dropdownOpenClasses);
    if (this.hasArrowIconTarget) this.arrowIconTarget.classList.add(...this.iconOpenClasses);
  }

  hide() {
    this.dropdownTarget.classList.remove(...this.showDropdownClasses);
    this.dropdownTarget.classList.add(...this.hideDropdownClasses);
    this.dropdownTarget.classList.remove(...this.dropdownOpenClasses);
    if (this.hasArrowIconTarget) this.arrowIconTarget.classList.remove(...this.iconOpenClasses);
  }

  _closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.hide();
  }
}
