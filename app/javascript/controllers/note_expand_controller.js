import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]

  connect() {
    // Check if content height exceeds max height
    if (this.contentTarget.scrollHeight > 360) {
      this.element.classList.add("expandable")
    } else {
      this.buttonTarget.style.display = "none"
    }
  }

  toggle() {
    const isExpanded = this.element.classList.toggle("expanded")
    this.buttonTarget.textContent = isExpanded ? "Show less" : "Show more"
  }
} 