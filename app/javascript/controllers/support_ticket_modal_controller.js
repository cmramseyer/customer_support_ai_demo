import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "comment", "dialog", "errors", "form", "submitButton", "trigger" ]

  open() {
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
    this.commentTarget.focus()
  }

  close() {
    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  async submit(event) {
    event.preventDefault()
    this.clearErrors()
    this.submitButtonTarget.disabled = true

    try {
      const response = await fetch(this.formTarget.action, {
        method: this.formTarget.method,
        headers: {
          Accept: "application/json",
          "X-Requested-With": "XMLHttpRequest"
        },
        body: new FormData(this.formTarget),
        credentials: "same-origin"
      })

      if (!response.ok) {
        const payload = await response.json()
        this.showErrors(payload.errors || [ "Unable to create the support ticket." ])
        return
      }

      this.formTarget.reset()
      this.close()
      this.triggerTarget.focus()
    } catch {
      this.showErrors([ "Unable to create the support ticket. Please try again." ])
    } finally {
      this.submitButtonTarget.disabled = false
    }
  }

  clearErrors() {
    this.errorsTarget.replaceChildren()
    this.errorsTarget.hidden = true
  }

  showErrors(errors) {
    this.errorsTarget.replaceChildren(...errors.map((error) => {
      const message = document.createElement("p")
      message.textContent = error
      return message
    }))
    this.errorsTarget.hidden = false
  }
}
