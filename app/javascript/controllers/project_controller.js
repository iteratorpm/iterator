import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';

export default class extends Controller {
  static values = { panelsResizable: Boolean }
  
  connect() {
    if (this.panelsResizableValue) {
      this.setupSortable()
    }
  }
  
  setupSortable() {
    new Sortable(this.element, {
      animation: 150,
      handle: 'header',
      draggable: '.panel-wrapper',
      ghostClass: 'bg-gray-100',
      onEnd: this.reorderPanels.bind(this)
    })
  }
  
  reorderPanels(event) {
    // Handle panel reordering logic here
    // You might want to send an AJAX request to save the new order
    console.log(`Moved panel from ${event.oldIndex} to ${event.newIndex}`)
  }
}
