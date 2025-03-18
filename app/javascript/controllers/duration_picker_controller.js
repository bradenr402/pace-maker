import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="duration-picker"
export default class extends Controller {
  static targets = ['hours', 'minutes', 'seconds', 'duration', 'hourPlural'];

  connect() {
    this.initScrollListeners();
    this.setInitialScrollPositions();
    this.hourPluralTimeout = null;
  }

  initScrollListeners() {
    [this.hoursTarget, this.minutesTarget, this.secondsTarget].forEach((picker) => {
      picker.addEventListener('scroll', () => this.updateDuration());
    });
  }

  setInitialScrollPositions() {
    const totalSeconds = parseInt(this.durationTarget.value) || 0;

    if (isNaN(totalSeconds) || totalSeconds === 0) return;

    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    this.scrollToValue(this.hoursTarget, hours);
    this.scrollToValue(this.minutesTarget, minutes);
    this.scrollToValue(this.secondsTarget, seconds);
  }

  getSelectedValue(container) {
    const items = Array.from(container.children).filter((item) => item.dataset.value !== undefined);
    if (items.length === 0) return 0; // Fallback

    // Get the vertical center of the container
    const containerRect = container.getBoundingClientRect();
    const containerCenter = containerRect.top + containerRect.height / 2;

    let closest = items[0];
    let closestDistance = Math.abs(
      items[0].getBoundingClientRect().top + items[0].offsetHeight / 2 - containerCenter,
    );

    for (let item of items) {
      const itemCenter = item.getBoundingClientRect().top + item.offsetHeight / 2;
      const distance = Math.abs(itemCenter - containerCenter);

      if (distance < closestDistance) {
        closest = item;
        closestDistance = distance;
      }
    }

    return parseInt(closest.dataset.value) || 0; // Default to 0 if NaN
  }

  updateDuration() {
    const hours = this.getSelectedValue(this.hoursTarget);
    const minutes = this.getSelectedValue(this.minutesTarget);
    const seconds = this.getSelectedValue(this.secondsTarget);

    if (isNaN(hours) && isNaN(minutes) && isNaN(seconds)) return;

    const totalSeconds = hours * 3600 + minutes * 60 + seconds;
    this.durationTarget.value = totalSeconds;
    this.updateHourPlural();

    this.durationTarget.dispatchEvent(new Event('change'));
  }

  updateHourPlural() {
    const hours = this.getSelectedValue(this.hoursTarget);

    if (isNaN(hours)) return;

    clearTimeout(this.hourPluralTimeout);

    this.hourPluralTimeout = setTimeout(() => {
      if (hours === 1) this.hourPluralTarget.classList.add('opacity-0');
      else this.hourPluralTarget.classList.remove('opacity-0');
    }, 200);
  }

  scrollTo(event) {
    const el = event.currentTarget;
    const value = parseInt(el.dataset.value);
    const list = el.dataset.list;

    let container = null;
    if (list === 'hours') {
      container = this.hoursTarget;
    } else if (list === 'minutes') {
      container = this.minutesTarget;
    } else if (list === 'seconds') {
      container = this.secondsTarget;
    } else return;

    this.scrollToValue(container, value);
  }

  scrollToValue(container, value) {
    const item = container.querySelector(`[data-value="${value}"]`);
    if (item) {
      container.scrollTo({
        top: item.offsetTop - container.offsetHeight / 2 + item.offsetHeight / 2,
        behavior: 'smooth',
      });
    }
  }
}
