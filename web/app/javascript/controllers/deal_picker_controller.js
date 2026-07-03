import { Controller } from "@hotwired/stimulus"

// Toggles which deal-type add form is visible for a day.
// Markup:
//   data-controller="deal-picker"
//   button data-action="deal-picker#show" data-deal-picker-type-param="generic"
//   div data-deal-picker-target="form" data-type="generic"
export default class extends Controller {
  static targets = ["form", "tab"]

  show(event) {
    const type = event.params.type
    this.formTargets.forEach((el) => {
      el.classList.toggle("hidden", el.dataset.type !== type)
    })
    this.tabTargets.forEach((el) => {
      const active = el.dataset.dealPickerTypeParam === type
      el.classList.toggle("bg-amber-500", active)
      el.classList.toggle("text-white", active)
      el.classList.toggle("bg-gray-100", !active)
      el.classList.toggle("text-gray-600", !active)
    })
  }
}
