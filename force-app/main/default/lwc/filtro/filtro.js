import { LightningElement, api } from "lwc";

export default class ListaFilter extends LightningElement {
  @api placeholder;

  filterChanged(event) {
    const filterChangedEvent = new CustomEvent("filterchanged", {
      detail: event.target.value
    });
    this.dispatchEvent(filterChangedEvent);
  }

  handleFocus() {
    if (window.innerWidth < 768) {
      this.fireFocus(true);
    }
  }

  handleFocusOut() {
    if (window.innerWidth < 768) {
      this.fireFocus(false);
    }
  }

  fireFocus(focus) {
    const filterFocusEvent = new CustomEvent('filterfocus', {
      detail: {
        focus
      }
    });
    this.dispatchEvent(filterFocusEvent);
  }
}