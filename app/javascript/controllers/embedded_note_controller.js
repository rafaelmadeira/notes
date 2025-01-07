import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    this.collapse()
  }

  toggle(event) {
    // Don't toggle if clicking on a link inside the note
    if (event.target.tagName === 'A') return

    if (this.element.classList.contains('expanded')) {
      this.collapse()
    } else {
      this.expand()
    }
  }

  collapse() {
    this.element.classList.remove('expanded')
  }

  expand() {
    this.element.classList.add('expanded')
  }
} 