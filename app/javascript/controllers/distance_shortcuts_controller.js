import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="distance-shortcuts"
export default class extends Controller {
  static targets = ['distance'];

  setDistance(event) {
    const distance = event.currentTarget.dataset.distanceValue;

    if (distance !== undefined) {
      this.distanceTarget.value = parseFloat(distance);
    }
  }
}
