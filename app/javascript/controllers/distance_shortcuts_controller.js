import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="distance-shortcuts"
export default class extends Controller {
  static targets = ['distance'];

  setDistance(event) {
    const distance = event.currentTarget.dataset.setDistanceValue;

    this.distanceTarget.value = parseFloat(distance);
  }

  updateDistance(event) {
    const updateDistanceValue = event.currentTarget.dataset.updateDistanceValue;

    if (this.distanceTarget.value === '') this.distanceTarget.value = 0;

    let currentValue = parseFloat(this.distanceTarget.value);
    currentValue += parseFloat(updateDistanceValue);
    this.distanceTarget.value = currentValue;
  }
}
