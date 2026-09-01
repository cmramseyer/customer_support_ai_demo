import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "body", "errors", "form", "list" ]

  async submit(event) {
    event.preventDefault()
    this.clearErrors()

    const submitButton = this.formTarget.querySelector("input[type=submit]")
    submitButton.disabled = true

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
      const payload = await response.json()

      if (!response.ok) {
        this.showErrors(payload.errors || [ "Unable to add the comment." ])
        return
      }

      this.listTarget.insertAdjacentHTML("beforeend", payload.html)
      this.formTarget.reset()
      this.bodyTarget.focus()
    } catch {
      this.showErrors([ "Unable to add the comment. Please try again." ])
    } finally {
      submitButton.disabled = false
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
