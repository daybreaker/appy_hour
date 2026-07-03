import { Controller } from "@hotwired/stimulus"

// Disables the start/end time inputs for a happy hour day when "All day" is
// checked (a disabled field submits no value, and the model skips the time
// validation and clears the times when all_day is set).
//
// Markup:
//   div data-controller="all-day"
//     input type=checkbox data-all-day-target="checkbox" data-action="all-day#toggle"
//     input (start) data-all-day-target="time"
//     input (end)   data-all-day-target="time"
export default class extends Controller {
  static targets = ["checkbox", "time"]

  connect() {
    this.toggle()
  }

  toggle() {
    const allDay = this.checkboxTarget.checked
    this.timeTargets.forEach((input) => {
      input.disabled = allDay
      input.classList.toggle("opacity-40", allDay)
    })
  }
}
