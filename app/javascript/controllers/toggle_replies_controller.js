import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="toggle-replies"
export default class extends Controller {
  static targets = ['button', 'container', 'icon', 'text'];
  static values = {
    hidden: Boolean,
    parentId: String,
    buttonHideText: String,
    buttonShowText: String,
  };

  toggleReplies() {
    this.hiddenValue = !this.hiddenValue;

    this.containerTargets.forEach((container) => {
      if (this.hiddenValue) this.collapse(container);
      else this.expand(container);
    });

    this.updateButton();
  }

  expand(container) {
    container.style.display = 'block';
    const height = container.scrollHeight + 'px';
    container.style.height = '0px';
    setTimeout(() => {
      container.style.height = height;
    }, 10);

    container.addEventListener('transitionend', function handler() {
      container.style.height = 'auto';
      container.removeEventListener('transitionend', handler);
    });
  }

  collapse(container) {
    const height = container.scrollHeight + 'px';
    container.style.height = height;
    setTimeout(() => {
      container.style.height = '0px';
    }, 10);

    container.addEventListener('transitionend', function handler() {
      container.style.display = 'none';
      container.removeEventListener('transitionend', handler);
    });
  }

  updateButton() {
    this.iconTargets.forEach((icon) => {
      if (this.hiddenValue) icon.classList.remove('rotate-180');
      else icon.classList.add('rotate-180');
    });

    this.textTargets.forEach((text) => {
      if (this.hiddenValue) text.textContent = this.buttonShowTextValue;
      else text.textContent = this.buttonHideTextValue;
    });
  }
}
