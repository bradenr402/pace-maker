import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="distance-shortcuts"
export default class extends Controller {
  static targets = ['distance'];

  setDistance(event) {
    const distance = event.currentTarget.dataset.distanceValue;

    this.distanceTarget.value = parseFloat(distance);
  }

  decrementDistance(event) {
    const decrementValue = event.currentTarget.dataset.decrementValue;

    if (this.distanceTarget.value === '') {
      this.distanceTarget.value = 0;
    }

    let currentValue = parseFloat(this.distanceTarget.value);
    currentValue -= parseFloat(decrementValue);
    this.distanceTarget.value = currentValue;
  }

  incrementDistance(event) {
    const incrementValue = event.currentTarget.dataset.incrementValue;

    if (this.distanceTarget.value === '') {
      this.distanceTarget.value = 0;
    }

    let currentValue = parseFloat(this.distanceTarget.value);
    currentValue += parseFloat(incrementValue);
    this.distanceTarget.value = currentValue;
  }
}
