import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="pinned-pages-menu"
export default class extends Controller {
  static targets = ['menu', 'openIcon', 'closeIcon'];
  static classes = ['hidden', 'visible'];

  connect() {
    this.closeOnOutsideClick = this._closeOnOutsideClick.bind(this);
    document.addEventListener('click', this.closeOnOutsideClick);
    this.hide();
  }

  disconnect() {
    document.removeEventListener('click', this.closeOnOutsideClick);
  }

  toggle() {
    if (this.menuTarget.classList.contains(...this.hiddenClasses)) this.show();
    else this.hide();
  }

  show() {
    this.menuTarget.classList.remove(...this.hiddenClasses);
    this.menuTarget.classList.add(...this.visibleClasses);
    this.openIconTarget.classList.add('hidden');
    this.closeIconTarget.classList.remove('hidden');
  }

  hide() {
    this.menuTarget.classList.remove(...this.visibleClasses);
    this.menuTarget.classList.add(...this.hiddenClasses);
    this.openIconTarget.classList.remove('hidden');
    this.closeIconTarget.classList.add('hidden');
  }

  _closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.hide();
  }
}
