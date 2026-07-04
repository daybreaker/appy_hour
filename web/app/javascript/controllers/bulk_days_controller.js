import { Controller } from "@hotwired/stimulus"

// Quick-select presets for the multi-day picker. Checks/unchecks the weekday
// checkboxes (values 0=Sun … 6=Sat).
//
// Markup:
//   data-controller="bulk-days"
//   checkbox: data-bulk-days-target="day" value="0..6"
//   preset buttons: data-action="bulk-days#weekdays" etc.
export default class extends Controller {
  static targets = ["day"]

  weekdays() { this.set([1, 2, 3, 4, 5]) }
  weekend() { this.set([0, 6]) }
  all() { this.set([0, 1, 2, 3, 4, 5, 6]) }
  clear() { this.set([]) }

  set(values) {
    this.dayTargets.forEach((cb) => {
      cb.checked = values.includes(parseInt(cb.value, 10))
    })
  }
}
