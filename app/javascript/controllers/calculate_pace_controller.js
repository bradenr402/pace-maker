import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="calculate-pace"
export default class extends Controller {
  static targets = ['distance', 'duration', 'pace'];

  connect() {
    this.paceTarget.closest('form')?.addEventListener('reset', () => this.resetPaceDisplay());
  }

  update() {
    const distance = parseFloat(this.distanceTarget.value) || 0;
    const totalSeconds = parseInt(this.durationTarget.value) || 0;

    if (isNaN(distance) || isNaN(totalSeconds) || distance === 0 || totalSeconds === 0) {
      this.resetPaceDisplay();
      return;
    }

    const paceInSeconds = totalSeconds / distance;
    const formattedPace = this.formatPace(paceInSeconds);
    this.paceTarget.textContent = formattedPace;
  }

  formatPace(paceInSeconds) {
    const paceMinutes = Math.floor(paceInSeconds / 60);
    const paceSeconds = Math.round(paceInSeconds % 60);
    return `${paceMinutes.toString().padStart(2, '0')}:${paceSeconds.toString().padStart(2, '0')}`;
  }

  resetPaceDisplay() {
    this.paceTarget.textContent = '--:--';
  }
}
