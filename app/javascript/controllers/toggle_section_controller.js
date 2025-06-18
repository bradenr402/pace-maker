import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="toggle-section"
export default class extends Controller {
  static targets = ['collapsible', 'arrowIcon', 'btnText'];
  static classes = ['collapsed'];

  toggle(event) {
    const btn = event.currentTarget;
    const id = btn.dataset.collapsibleId;

    const collapsible = this._findElementById(this.collapsibleTargets, `collapsible_${id}`);

    if (!collapsible) return;

    const isCollapsed = collapsible.dataset.collapsed == 'true';
    this._toggleCollapsible(collapsible, isCollapsed);

    const arrowIcon = this._findElementById(this.arrowIconTargets, `arrow_${id}`);
    this._toggleIcon(arrowIcon, isCollapsed);

    const btnText = this._findElementById(this.btnTextTargets, `btnText_${id}`);
    this._toggleText(btnText, isCollapsed);
  }

  _findElementById(targets, id) {
    return targets.find((el) => el.id == id);
  }

  _toggleCollapsible(collapsible, isCollapsed) {
    if (isCollapsed) {
      collapsible.dataset.collapsed = 'false';
      collapsible.classList.remove(...this.collapsedClasses);
    } else {
      collapsible.dataset.collapsed = 'true';
      collapsible.classList.add(...this.collapsedClasses);
    }
  }

  _toggleIcon(icon, isCollapsed) {
    icon?.classList.toggle('rotate-180', !isCollapsed);
  }

  _toggleText(text, isCollapsed) {
    if (text) text.textContent = isCollapsed ? 'Collapse' : 'Expand';
  }
}
