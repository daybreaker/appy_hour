import { Controller } from "@hotwired/stimulus"

// Adds/removes nested form rows (e.g. happy hour day fields).
// Markup:
//   data-controller="nested-form"
//   data-nested-form-target="rows"      -> container the new rows are appended to
//   data-nested-form-target="template"  -> <template> holding a blank row with NEW_RECORD placeholder
//   data-action="nested-form#add"       -> button that appends a new row
//   data-action="nested-form#remove"    -> button inside a row that removes/marks it
export default class extends Controller {
  static targets = ["rows", "template"]

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest("[data-nested-form-target='row']")
    const destroyFlag = row.querySelector("input[name*='_destroy']")

    if (destroyFlag) {
      // Persisted record: mark for destruction and hide.
      destroyFlag.value = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
  }
}
