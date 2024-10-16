import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="calculate-pace"
export default class extends Controller {
  static targets = ['distance', 'duration', 'pace'];

  update() {
    const distance = parseFloat(this.distanceTarget.value);
    const durationString = this.durationTarget.value;
    const durationRegex = /^((2[0-3]|1\d|0?\d):)?([0-5]?\d):([0-5]\d)$/; // refer to form_validation_controller.js

    if (durationString == '') {
      this.paceTarget.textContent = 'XX:XX';
      return;
    }

    if (isNaN(distance) || distance < 0 || !durationRegex.test(durationString))
      return;

    const durationParts = durationString.split(':').map(Number);
    let totalSeconds;

    if (durationParts.length === 2) {
      totalSeconds = durationParts[0] * 60 + durationParts[1];
    } else if (durationParts.length === 3) {
      totalSeconds =
        durationParts[0] * 3600 + durationParts[1] * 60 + durationParts[2];
    } else {
      return;
    }

    const paceInSeconds = totalSeconds / distance;
    const paceMinutes = Math.floor(paceInSeconds / 60);
    const paceSeconds = Math.round(paceInSeconds % 60);

    this.paceTarget.textContent = `${paceMinutes}:${paceSeconds
      .toString()
      .padStart(2, '0')}`;
  }
}
