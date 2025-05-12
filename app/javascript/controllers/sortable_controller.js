import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';
import { put } from '@rails/request.js'

export default class extends Controller {
  static values = {
    column: String,  // e.g., "icebox", "unstarted", or "epic_123"
    type: { type: String, default: "story" },
    persist: { type: Boolean, default: true },
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      group: {
        name: this.typeValue,
        pull: true,
        put: true,
      },
      draggable: `.${this.typeValue}`,
      filter: ".undraggable",
      preventOnFilter: false,
      dataIdAttr: "data-id",
      scrollSensitivity: 75,
      delay: 200,
      delayOnTouchOnly: true,
      onStart: e => e.item.setAttribute("data-turbo-permanent", "true"),
      onEnd: e => e.item.removeAttribute("data-turbo-permanent"),
      onMove: e => this.onMove(e),
      onSort: e => this.onSort(e),
    })
  }

  onMove(event) {
    if (event.originalEvent.target.closest(".undraggable")) {
      return false
    }

    const from = event.from.dataset.sortableColumnValue
    const to = event.to.dataset.sortableColumnValue
    const action = [to, from].sort().join()

    if (from === to) return true;

    // Only allow moving between icebox and unstarted, or to epic_ columns
    if (action === "icebox,unstarted") return true
    if (to?.startsWith("epic_") && from?.startsWith("epic_")) return true
    return false
  }

  onSort(event) {
    if (!this.persistValue) return

    const item = event.item
    const storyId = item.dataset.id
    const fromColumn = event.from.dataset.sortableColumnValue
    const toColumn = event.to.dataset.sortableColumnValue

    const url = `${location.href}/stories/${storyId}`

    const payload = {
      position: this.calculatePosition(item)
    }

    // State update
    if (fromColumn !== toColumn) {
      payload.state = this.mapColumnToState(toColumn)
    }

    // Epic label support
    const epicLabel = event.to.parentElement?.dataset.epicLabel
    if (epicLabel) {
      payload.add_label = epicLabel
    }

    if (this.hasPositioningColumnValue) {
      payload.column = this.columnValue
    }

    const requestUID = uuid()

    put(url, {
      body: {
        story: payload
      },
      headers: {
        "X-Turbo-Request-Id": requestUID,
        Accept: "application/json"
      }
    })

    Turbo.session.recentRequests.add(requestUID)
  }

  mapColumnToState(column) {
    if (column === "icebox") return "unscheduled"
    if (column === "unstarted") return "unstarted"
    return undefined
  }

  calculatePosition(item) {
    const siblings = Array.from(item.parentNode.querySelectorAll(`.${this.typeValue}`))
    const index = siblings.indexOf(item)
    const before = siblings[index + 1]
    const after = siblings[index - 1]

    if (after) return { after: after.dataset.id }
    if (before) return { before: before.dataset.id }
    return "last"
  }
}

// UUID generator
function uuid() {
  return Array.from({ length: 36 })
    .map((_, i) => {
      if (i == 8 || i == 13 || i == 18 || i == 23) return "-"
      if (i == 14) return "4"
      if (i == 19) return (Math.floor(Math.random() * 4) + 8).toString(16)
      return Math.floor(Math.random() * 15).toString(16)
    }).join("")
}
