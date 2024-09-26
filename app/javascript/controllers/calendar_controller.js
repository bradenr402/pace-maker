import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="calendar"
export default class extends Controller {
  static targets = ['toggleButtonText', 'calendarContainer'];
  static classes = ['hidden', 'visible'];

  toggleCalendar() {
    if (this.calendarContainerTarget.classList.contains(...this.hiddenClasses)) {
      this.calendarContainerTarget.classList.remove(...this.hiddenClasses);
      this.calendarContainerTarget.classList.add(...this.visibleClasses);
      this.toggleButtonTextTarget.textContent = 'Hide calendar';
    } else {
      this.calendarContainerTarget.classList.add(...this.hiddenClasses);
      this.calendarContainerTarget.classList.remove(...this.visibleClasses);
      this.toggleButtonTextTarget.textContent = 'Show calendar';
    }
  }
}
