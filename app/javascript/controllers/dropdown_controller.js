import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ['dropdown', 'arrowIcon'];
  static classes = ['hideDropdown', 'showDropdown', 'iconOpen', 'dropdownOpen'];

  connect() {
    console.log('dropdown controller connected');


    this.closeOnOutsideClick = this._closeOnOutsideClick.bind(this);
    document.addEventListener('click', this.closeOnOutsideClick);

    this.hide();
  }

  disconnect() {
    document.removeEventListener('click', this.closeOnOutsideClick);
  }

  toggle() {
    if (this.dropdownTarget.classList.contains(...this.hideDropdownClasses))
      this.show();
    else this.hide();
  }

  show() {
    this.dropdownTarget.classList.remove(...this.hideDropdownClasses);
    this.dropdownTarget.classList.add(...this.showDropdownClasses);
    this.arrowIconTarget.classList.add(...this.iconOpenClasses);
    this.element.classList.add(...this.dropdownOpenClasses);
  }

  hide() {
    this.dropdownTarget.classList.remove(...this.showDropdownClasses);
    this.dropdownTarget.classList.add(...this.hideDropdownClasses);
    this.arrowIconTarget.classList.remove(...this.iconOpenClasses);
    this.element.classList.remove(...this.dropdownOpenClasses);
  }

  _closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.hide();
  }
}
