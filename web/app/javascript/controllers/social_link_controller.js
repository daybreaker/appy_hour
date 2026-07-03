import { Controller } from "@hotwired/stimulus"

// Shows the URL prefix for the selected social platform next to the handle
// input (e.g. picking Instagram shows "instagram.com/"), so admins only type
// the username.
//
// Markup:
//   div data-controller="social-link" data-social-link-prefixes-value="{...}"
//     select data-social-link-target="platform" data-action="social-link#update"
//     span   data-social-link-target="prefix"
export default class extends Controller {
  static targets = ["platform", "prefix"]
  static values = { prefixes: Object }

  connect() {
    this.update()
  }

  update() {
    this.prefixTarget.textContent = this.prefixesValue[this.platformTarget.value] || ""
  }
}
