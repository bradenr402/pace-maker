import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="filter-events"
export default class extends Controller {
  static targets = ['radio', 'event'];

  connect() {
    this.filter();
  }

  getValue() {
    const selectedRadio = this.radioTargets.find((radio) => radio.checked);
    return selectedRadio ? selectedRadio.value : null;
  }

  filter() {
    const selectedValue = this.getValue();

    this.updateURL(selectedValue);

    if (selectedValue === 'upcoming') this.showUpcomingEvents();
    else if (selectedValue === 'past') this.showPastEvents();
    else if (selectedValue === 'current') this.showCurrentEvents();
    else this.showAllEvents();
  }

  updateURL(filterValue) {
    const url = new URL(window.location);

    if (filterValue) url.searchParams.set('filter', filterValue);
    else url.searchParams.delete('filter');

    history.replaceState(null, '', url.toString());
  }

  showAllEvents() {
    this.eventTargets.forEach((event) => {
      event.classList.remove('hidden');
    });
  }

  showUpcomingEvents() {
    this.eventTargets.forEach((event) => {
      if (event.dataset.eventStatus === 'upcoming') event.classList.remove('hidden');
      else event.classList.add('hidden');
    });
  }

  showPastEvents() {
    this.eventTargets.forEach((event) => {
      if (event.dataset.eventStatus === 'past') event.classList.remove('hidden');
      else event.classList.add('hidden');
    });
  }

  showCurrentEvents() {
    this.eventTargets.forEach((event) => {
      if (event.dataset.eventStatus === 'current') event.classList.remove('hidden');
      else event.classList.add('hidden');
    });
  }
}
