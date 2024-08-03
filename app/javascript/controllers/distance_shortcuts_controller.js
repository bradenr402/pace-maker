import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="distance-shortcuts"
export default class extends Controller {
  static targets = ['distance'];

  setDistance(event) {
    const distance = parseFloat(event.currentTarget.dataset.setDistanceValue);
    this.distanceTarget.value = distance.toFixed(1);
  }

  updateDistance(event) {
    const updateDistanceValue = parseFloat(
      event.currentTarget.dataset.updateDistanceValue
    );

    if (this.distanceTarget.value === '') this.distanceTarget.value = 0;

    let currentValue = parseFloat(this.distanceTarget.value);
    currentValue += updateDistanceValue;
    this.distanceTarget.value = currentValue.toFixed(1);
  }
}
