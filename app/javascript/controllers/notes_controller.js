import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.toggleSubmitButton()
    this.resizeTextarea()
    
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
    this.resizeTextarea()
  }

  toggleSubmitButton() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !this.inputTarget.value.trim()
    }
  }

  inputChanged() {
    this.toggleSubmitButton()
    this.resizeTextarea()
  }

  resizeTextarea() {
    const textarea = this.inputTarget
    // Reset height to auto to get the correct scrollHeight
    textarea.style.height = 'auto'
    // Set the height to match the content
    textarea.style.height = textarea.scrollHeight + 'px'
  }
} 