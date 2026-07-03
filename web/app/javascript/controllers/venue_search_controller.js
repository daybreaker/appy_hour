import { Controller } from "@hotwired/stimulus"

// Search-as-you-type venue picker. Debounces input, fetches an HTML result
// fragment from the server, and on selection sets a hidden venue_id field.
//
// Markup:
//   div data-controller="venue-search" data-venue-search-url-value="/admin/venues/search"
//     input data-venue-search-target="query" data-action="input->venue-search#search"
//     input type="hidden" data-venue-search-target="venueId" name="happy_hour[venue_id]"
//     div data-venue-search-target="results"
//   result buttons: data-action="venue-search#select"
//                   data-venue-search-id-param / data-venue-search-name-param
export default class extends Controller {
  static targets = ["query", "venueId", "results"]
  static values = { url: String }

  search() {
    clearTimeout(this.timeout)
    const q = this.queryTarget.value.trim()

    // Typing a new query invalidates any prior selection.
    this.venueIdTarget.value = ""

    if (q.length < 2) {
      this.resultsTarget.innerHTML = ""
      return
    }

    this.timeout = setTimeout(() => this.fetchResults(q), 200)
  }

  async fetchResults(q) {
    const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(q)}`, {
      headers: { Accept: "text/html" },
    })
    this.resultsTarget.innerHTML = await response.text()
  }

  select(event) {
    this.venueIdTarget.value = event.params.id
    this.queryTarget.value = event.params.name
    this.resultsTarget.innerHTML = ""
  }

  // Hide the dropdown when focus leaves the widget.
  dismiss(event) {
    if (!this.element.contains(event.relatedTarget)) {
      setTimeout(() => (this.resultsTarget.innerHTML = ""), 150)
    }
  }
}
