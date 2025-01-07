import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
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
  }
} 