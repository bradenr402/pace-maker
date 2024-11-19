import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="calculate-pace"
export default class extends Controller {
  static targets = ['distance', 'duration', 'pace'];

  connect() {
    this.paceTarget.closest('form')?.addEventListener('reset', () => this.resetPaceDisplay());
  }

  update() {
    const distance = parseFloat(this.distanceTarget.value);
    const durationString = this.durationTarget.value;
    const durationRegex = /^((2[0-3]|1\d|0?\d):)?([0-5]?\d):([0-5]\d)$/; // refer to form_validation_controller.js

    if (!this.isValidInput(distance, durationString, durationRegex)) return;

    const totalSeconds = this.calculateTotalSeconds(durationString);
    if (!totalSeconds) return;

    const paceInSeconds = totalSeconds / distance;
    const formattedPace = this.formatPace(paceInSeconds);

    this.paceTarget.textContent = formattedPace;
  }

  isValidInput(distance, durationString, durationRegex) {
    if (durationString === '') {
      this.resetPaceDisplay();
      return false;
    }
    return !(isNaN(distance) || distance < 0 || !durationRegex.test(durationString));
  }

  calculateTotalSeconds(durationString) {
    const durationParts = durationString.split(':').map(Number);

    if (durationParts.length === 2) {
      return durationParts[0] * 60 + durationParts[1];
    } else if (durationParts.length === 3) {
      return durationParts[0] * 3600 + durationParts[1] * 60 + durationParts[2];
    }
    return null;
  }

  formatPace(paceInSeconds) {
    const paceMinutes = Math.floor(paceInSeconds / 60);
    const paceSeconds = Math.round(paceInSeconds % 60);
    return `${paceMinutes}:${paceSeconds.toString().padStart(2, '0')}`;
  }
  
  resetPaceDisplay() {
    this.paceTarget.textContent = 'XX:XX';
  }
}
