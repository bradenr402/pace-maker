import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="carousel"
export default class extends Controller {
  static targets = ['carousel', 'item'];

  scrollLeft() {
    const itemWidth = this.itemTargets[0].offsetWidth;
    this.carouselTarget.scrollBy({
      left: -itemWidth,
      behavior: 'smooth',
    });
  }

  scrollRight() {
    const itemWidth = this.itemTargets[0].offsetWidth;
    this.carouselTarget.scrollBy({
      left: itemWidth,
      behavior: 'smooth',
    });
  }
}
