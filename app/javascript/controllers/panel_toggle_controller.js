import { Controller } from "@hotwired/stimulus"
import Cookies from "js-cookie"

export default class extends Controller {
  persist() {
    const key = this.element.name
    const value = this.element.checked ? "1" : ""
    Cookies.set(key, value, { expires: 365 })
    
    // Dispatch event to update panels
    this.dispatch("change", {
      detail: { 
        panel: this.element.dataset.panelName,
        visible: this.element.checked 
      }
    })
  }
}
