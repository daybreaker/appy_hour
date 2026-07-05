require "ferrum"

module Scrapers
  # Headless-Chrome fetch for JS-rendered / gated sites. Renders the page,
  # tries to get past age gates (DOB 10/17/1981) and "enter" splash pages, then
  # extracts text + a broad set of same-domain links to follow. PDFs are read
  # over plain HTTP (Chrome can't easily hand us PDF text).
  #
  # Same #fetch(url) -> Result interface as WebsiteFetcher, so it's a drop-in
  # for the scrapers. Reuse one instance across a run and #close it when done —
  # launching Chrome is expensive.
  class BrowserFetcher
    DEFAULT_CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome".freeze
    AFFIRM_TEXT = /\A\s*(enter|yes|i am|i'm|over ?21|21\+|confirm|agree|accept|continue|of age|proceed)/i
    DOB = { month: "10", day: "17", year: "1981", full: "10/17/1981" }.freeze
    RENDER_WAIT = 2.5

    Result = WebsiteFetcher::Result

    def initialize(browser: nil, http: WebsiteFetcher.new)
      @browser = browser || build_browser
      @http = http # for PDFs
    end

    def fetch(url)
      return Result.new(error: "blank url") if url.blank?
      return @http.fetch(url) if PageContent.pdf?(url, nil) # let HTTP+pdf-reader handle PDFs

      page = @browser.create_page
      page.go_to(url)
      sleep RENDER_WAIT
      dismiss_gates(page)
      html = page.body

      Result.new(
        html: html,
        text: PageContent.text_from_html(html),
        menu_links: PageContent.links_from_html(html, url, limit: 8, broad: true),
        social_links: SocialLinkDetector.detect(html)
      )
    rescue StandardError => e
      Result.new(error: "browser: #{e.class}: #{e.message}")
    ensure
      page&.close
    end

    def close
      @browser&.quit
    rescue StandardError
      nil
    end

    private

    # Best-effort: fill any date-of-birth fields, then click a plausible
    # affirmative / "enter" control, and re-wait for the real content.
    def dismiss_gates(page)
      changed = fill_dob(page)
      changed ||= click_affirmative(page)
      sleep RENDER_WAIT if changed
    end

    def fill_dob(page)
      filled = false

      # A single date input.
      if (input = page.at_css("input[type=date]"))
        type_into(input, "1981-10-17")
        filled = true
      end

      # Separate month/day/year fields (inputs or selects).
      %i[month day year].each do |part|
        node = page.at_css("input[name*='#{part}' i], input[id*='#{part}' i], " \
                           "select[name*='#{part}' i], select[id*='#{part}' i]")
        next unless node

        type_into(node, DOB[part])
        filled = true
      end

      filled
    end

    def click_affirmative(page)
      candidates = page.css("button, a, input[type=submit], input[type=button]")
      target = candidates.find do |n|
        label = (n.text.to_s.presence || n.attribute("value").to_s.presence || n.attribute("alt").to_s)
        label.to_s.match?(AFFIRM_TEXT)
      end
      # Fallback: an "enter" splash is often a lone image link.
      target ||= page.at_css("#enter a, a#enter, .enter a")

      return false unless target

      target.click
      true
    rescue StandardError
      false
    end

    def type_into(node, value)
      if node.tag_name.casecmp?("select")
        node.evaluate("this.value = '#{value}'; this.dispatchEvent(new Event('change', { bubbles: true }))")
      else
        node.focus
        node.type(value)
      end
    rescue StandardError
      nil
    end

    def build_browser
      Ferrum::Browser.new(
        headless: true,
        browser_path: ENV.fetch("CHROME_PATH", DEFAULT_CHROME),
        timeout: 30,
        process_timeout: 30,
        pending_connection_errors: false
      )
    end
  end
end
