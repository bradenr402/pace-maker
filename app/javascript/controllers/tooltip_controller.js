import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="tooltip"
export default class extends Controller {
  static targets = ['tooltip', 'content'];

  connect() {
    this.mousePointer = window.matchMedia('(pointer: fine)').matches;
    if (this.mousePointer) {
      document.addEventListener('mousemove', this.handleMouseMove.bind(this));
    } else {
      document.addEventListener('click', this.handleOutsideClick.bind(this));
      document.addEventListener('touchstart', this.handleOutsideClick.bind(this));
    }
  }

  disconnect() {
    if (this.mousePointer) {
      document.removeEventListener('mousemove', this.handleMouseMove.bind(this));
    } else {
      document.removeEventListener('click', this.handleOutsideClick.bind(this));
      document.removeEventListener('touchstart', this.handleOutsideClick.bind(this));
    }
  }

  showTooltip() {
    this.contentTarget.classList.remove('opacity-0', 'delay-75');
    this.contentTarget.classList.add('opacity-100');
    this.contentTarget.dataset.hidden = false;

    this.positionTooltip(this.contentTarget);
  }

  hideTooltip() {
    this.contentTarget.classList.add('opacity-0', 'delay-75');
    this.contentTarget.classList.remove('opacity-100');
    this.contentTarget.dataset.hidden = true;
  }

  toggle() {
    if (this.contentTarget.dataset.hidden === 'true') this.showTooltip();
    else this.hideTooltip();
  }

  positionTooltip(tooltipElement) {
    if (this.mousePointer) {
      // Position tooltip relative to the cursor
      document.addEventListener('mousemove', (event) => {
        let top = event.clientY - tooltipElement.offsetHeight - 3;
        let left = event.clientX + 3;

        // Adjust tooltip position if it's going to be clipped by the viewport
        if (left + tooltipElement.offsetWidth > window.innerWidth) {
          left = window.innerWidth - tooltipElement.offsetWidth - 5;
        }

        tooltipElement.style.top = `${top < 0 ? event.clientY + 5 : top}px`;
        tooltipElement.style.left = `${left < 5 ? 5 : left}px`;
      });
    } else {
      // Position tooltip relative to the parent element
      const rect = this.tooltipTarget.getBoundingClientRect();
      const tooltipRect = tooltipElement.getBoundingClientRect();

      let top = rect.top - tooltipRect.height - 5;
      let left = rect.left + (rect.width - tooltipRect.width) / 2 + tooltipRect.width / 2;

      // Adjust tooltip position if it's going to be clipped by the viewport
      if (top < 0) top = rect.bottom + 5;
      if (left < 0) left = 5;
      if (left + tooltipRect.width > window.innerWidth)
        left = window.innerWidth - tooltipRect.width - 5;

      tooltipElement.style.top = `${top}px`;
      tooltipElement.style.left = `${left}px`;
    }
  }

  handleMouseMove(event) {
    if (!this.contentTarget.dataset.hidden) {
      this.positionTooltip(this.contentTarget);
    }
  }

  handleOutsideClick(event) {
    if (!this.tooltipTarget.contains(event.target) && !this.contentTarget.contains(event.target))
      this.hideTooltip();
  }
}
