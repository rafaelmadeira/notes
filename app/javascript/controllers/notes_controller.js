import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.toggleSubmitButton()
    
    document.addEventListener('click', (event) => {
      if (event.target.classList.contains('reply-button')) {
        this.handleReply(event)
      }
    })
  }

  handleReply(event) {
    const noteId = event.target.dataset.noteId
    const input = this.inputTarget
    input.value = `[[${noteId}]]\n`
    input.focus()
    this.toggleSubmitButton()
  }

  toggleSubmitButton() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !this.inputTarget.value.trim()
    }
  }

  inputChanged() {
    this.toggleSubmitButton()
  }
} 