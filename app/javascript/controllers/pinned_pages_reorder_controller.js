import { Controller } from '@hotwired/stimulus';
import Sortable from 'sortablejs';

// Connects to data-controller="pinned-pages-reorder"
export default class extends Controller {
  static targets = ['list', 'orderInput'];

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      handle: '.drag-handle',
      swapThreshold: 0.75,
      animation: 200,
      onEnd: this.reorder.bind(this),
    });
  }

  reorder(event) {
    const ids = Array.from(this.listTarget.children).map(
      (item) => item.dataset.id
    );

    this.orderInputTarget.value = ids.join(', ');
  }
}
