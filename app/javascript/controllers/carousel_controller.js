import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="carousel"
export default class extends Controller {
  static targets = ['carousel', 'item'];

  scrollLeft() {
    const itemWidth = this.itemTargets[0].offsetWidth;
    const currentScroll = this.carouselTarget.scrollLeft;
    const newScroll = Math.round((currentScroll - itemWidth) / itemWidth) * itemWidth;

    this.carouselTarget.scrollTo({
      left: newScroll,
      behavior: 'smooth',
    });
  }

  scrollRight() {
    const itemWidth = this.itemTargets[0].offsetWidth;
    const currentScroll = this.carouselTarget.scrollLeft;
    const newScroll = Math.round((currentScroll + itemWidth) / itemWidth) * itemWidth;

    this.carouselTarget.scrollTo({
      left: newScroll,
      behavior: 'smooth',
    });
  }
}
