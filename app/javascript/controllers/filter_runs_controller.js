import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="filter-runs"
export default class extends Controller {
  static targets = ['radio', 'run'];

  connect() {
    this.filter();
  }

  getValue() {
    let radios = null;

    if (this.hasRadioTarget) radios = this.radioTargets;
    else radios = Array.from(document.querySelectorAll("[data-filter-runs-target='radio']"));

    const selectedRadio = radios.find((radio) => radio.checked);
    return selectedRadio ? parseFloat(selectedRadio.value) : null;
  }

  getFilterType() {
    let radios = null;

    if (this.hasRadioTarget) radios = this.radioTargets;
    else radios = Array.from(document.querySelectorAll("[data-filter-runs-target='radio']"));

    const selectedRadio = radios.find((radio) => radio.checked);
    return selectedRadio ? selectedRadio.dataset.filterType : null;
  }

  filter() {
    const selectedValue = this.getValue();
    const filterType = this.getFilterType();

    if (selectedValue && filterType) this.filterByDistance(selectedValue, filterType);
    else this.showAllRuns();
  }

  getRuns() {
    return Array.from(document.querySelectorAll("[data-filter-runs-target='run']"));
  }

  showAllRuns() {
    const runs = this.getRuns();

    runs.forEach((run) => run.classList.remove('hidden'));
  }

  filterByDistance(distance, filterType) {
    const runs = this.getRuns();

    runs.forEach((run) => {
      const runDistance = parseFloat(run.dataset.distance);
      if (!runDistance || isNaN(runDistance)) return;

      if (
        (filterType === 'greater_than' && runDistance >= distance) ||
        (filterType === 'less_than' && runDistance < distance)
      ) {
        run.classList.remove('hidden');
      } else {
        run.classList.add('hidden');
      }
    });
  }
}
