import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="calendar"
export default class extends Controller {
  static targets = ['toggleButtonText', 'calendarContainer'];
  static classes = ['hidden', 'visible'];

  connect() {
    if (this.hasToggleButtonTextTarget && this.hasCalendarContainerTarget)
      this.hideCalendar();
  }

  toggleCalendar() {
    if (this.calendarContainerTarget.classList.contains(...this.hiddenClasses))
      this.showCalendar();
    else this.hideCalendar();
  }

  hideCalendar() {
    this.calendarContainerTarget.classList.add(...this.hiddenClasses);
    this.calendarContainerTarget.classList.remove(...this.visibleClasses);
    this.toggleButtonTextTarget.textContent = 'Show calendar';
  }

  showCalendar() {
    this.calendarContainerTarget.classList.remove(...this.hiddenClasses);
    this.calendarContainerTarget.classList.add(...this.visibleClasses);
    this.toggleButtonTextTarget.textContent = 'Hide calendar';
  }
}
