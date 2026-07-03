# AppyHour — Rails Web App

Rails 8.1.3 · PostgreSQL + PostGIS · Hotwire/Turbo/Stimulus · Tailwind CSS

Full-stack Rails app serving both the Hotwire web UI and the `api/v1` REST namespace consumed by the Expo mobile app.

---

## Development Philosophy

**TDD is required.** Write the spec first, then the implementation. No model, service, controller, or scraper should be added without a corresponding spec written first. Red → green → refactor.

**Use idiomatic Rails.** Reach for what Rails already gives you before inventing something custom:
- Validations, callbacks, scopes, associations, concerns, enums — use them
- `before_action`, `after_commit`, `has_many :through`, `delegate` — use them
- Service objects are for multi-step workflows that don't belong in a model or controller, not a default wrapper for everything
- If you're fighting the framework, you're probably doing it wrong

---

## Directory Layout (notable paths)

```
app/
  controllers/
    application_controller.rb         # Web base — Devise session auth, CSRF on
    concerns/
    admin/
      base_controller.rb              # Admin base — requires admin role
    api/
      v1/
        base_controller.rb            # API base — token auth, CSRF off, JSON only
  models/
  services/                           # Multi-step business logic
    happy_hours/
      approval_service.rb
    venues/
      scraper_ingestion_service.rb
  serializers/                        # Blueprinter — API responses only, not used in web views
  views/                              # ERB + Turbo Stream templates
  jobs/                               # Sidekiq jobs
lib/
  scrapers/
    venue_discovery_scraper.rb        # Google Places API → find Venue candidates
    happy_hour_scraper.rb             # Fetch site → parse with Nokogiri + Claude LLM
spec/
  models/
  requests/                           # API endpoint specs
  system/                             # Capybara system specs (web UI flows)
  factories/
  support/
```

---

## Gem Stack

### Database / Location
- `activerecord-postgis-adapter` — replaces `pg` as the ActiveRecord adapter (PostGIS)
- `rgeo` — Ruby geometry library, required by postgis adapter
- `geocoder` — address → lat/lng lookup when creating a Venue

### Auth & Authorization
- `devise` — authentication (web sessions + API tokens)
- `cancancan` — role-based authorization (`Ability` class)

### Background Jobs
- `sidekiq` — job processing (replaces Solid Queue, which was installed by default)
- `sidekiq-cron` — cron scheduling for weekly/monthly scraper runs
- `redis` — Sidekiq backend

> Note: Solid Cache and Solid Cable (installed by Rails) are kept as-is.
> Only Solid Queue is replaced by Sidekiq.

### API
- `rack-cors` — CORS headers for Expo mobile app (configured in `config/initializers/cors.rb`)
- `rack-attack` — rate limiting on `api/v1` endpoints
- `blueprinter` — serializers for API JSON responses

### Scraper
- `faraday` + `faraday-retry` — HTTP client for Google Places + website fetching
- `nokogiri` — HTML parsing (already a Rails dependency, explicitly used in scrapers)
- `anthropic` — Claude API for LLM-assisted happy hour menu extraction

### Search & Pagination
- `pg_search` — PostgreSQL full-text search on Venue name/description
- `pagy` — pagination (fast, no magic)

### Notifications
- `noticed` — multi-channel notification system. Start with email, expand to SMS (Twilio) and push later without rearchitecting.

### Soft Deletes
- `discard` — soft deletes via `discarded_at` timestamp column. Cleaner than `paranoia`.

### Testing
- `rspec-rails`
- `factory_bot_rails`
- `faker`
- `shoulda-matchers`
- `capybara`
- `webmock` — stub all outbound HTTP in tests (Google Places, Claude API, scraped websites)

---

## Controller Conventions

### Web controllers (inherit `ApplicationController`)
- Devise `authenticate_user!` via `before_action`
- Render ERB views and Turbo Streams
- CSRF protection on

### API controllers (inherit `Api::V1::BaseController`)
- Token-based authentication via `before_action :authenticate_api_user!`
- `protect_from_forgery with: :null_session`
- Respond with JSON via Blueprinter serializers
- Return consistent error shapes: `{ error: "message" }`

### Admin controllers (inherit `Admin::BaseController`)
- `before_action :require_admin` (checks `current_user.admin?`)
- No API here — admin is web-only

**Thin controllers always.** A controller action should only: find/authorize the resource, call a service or model method, and respond. If it does more, extract it.

---

## Models

- Validations and scopes live in models
- Define named scopes for common queries: `.approved`, `.pending`, `.for_day(n)`, `.needs_review`
- Use `enum` for `status`, `role`, `discount_type`, `day_of_week`, etc.
- Use `discard` for soft deletes (`include Discard::Model`)
- Polymorphic associations: `Rating` and `Comment` are `rateable`/`commentable` on both `Venue` and `HappyHour`
- PostGIS: `Venue` has `lonlat geography(Point, 4326)`. Radius search uses `ST_DWithin`.

---

## Service Objects

`app/services/` for multi-step workflows only. Name them by domain and action:

```ruby
# app/services/happy_hours/approval_service.rb
module HappyHours
  class ApprovalService
    def initialize(happy_hour, approver)
    def approve!    # sets status, records approver, sends notification
    def reject!(reason:)
  end
end
```

Do not wrap simple CRUD in service objects. Use them when:
- Multiple models are touched in sequence
- Side effects (notifications, scraper triggers) are part of the operation
- The logic would make a controller or model hard to read/test

---

## Scraper Architecture

All scraper classes live under `lib/scrapers/` in the `Scrapers::` namespace
(autoloaded via `config.autoload_lib`). They are built from small, injectable
collaborators so each is unit-testable with fakes / WebMock — no real API calls
in the test suite.

### Collaborators
- **`Scrapers::GooglePlacesClient`** — Google Places API (New) `searchNearby`; returns normalized `Place` structs. Key: `credentials.google.places_api_key` or `GOOGLE_PLACES_API_KEY`.
- **`Scrapers::WebsiteFetcher`** — Faraday + Nokogiri; returns a `Result` with extracted text and candidate menu/happy-hour links. Failures return `Result#failed?`, never raise.
- **`Scrapers::ClaudeClient`** — thin wrapper over the Anthropic SDK. `#complete(prompt:, system:)` uses `claude-opus-4-8`, adaptive thinking, streaming (`messages.stream(...).accumulated_text`). Key: `ANTHROPIC_API_KEY`.
- **`Scrapers::HappyHourExtractor`** — sends page text to Claude, parses the JSON response (tolerant of prose/fences), returns a normalized Hash or nil.
- **`Scrapers::HappyHourPersister`** — turns extracted data into a `HappyHour` + days + deals, all `status: :pending`.

### VenueDiscoveryScraper (`lib/scrapers/venue_discovery_scraper.rb`)
`call(lat:, lng:, radius:, neighborhood:)` — queries `GooglePlacesClient`, upserts `Venue` records deduped on `google_place_id` (unique column), stores PostGIS location, returns only the newly created venues.

### HappyHourScraper (`lib/scrapers/happy_hour_scraper.rb`)
`HappyHourScraper.new(venue).call` orchestrates:
1. Fetch website (`WebsiteFetcher`) — no website / fetch error → `ScraperRun(fetch_failed)`, venue `scrape_failed` + `needs_investigation`.
2. **Keyword pre-filter (no AI cost):** scan the Nokogiri-extracted text for `HAPPY_HOUR_HINT` (`/happy\s*-?\s*hour/i`). If the homepage doesn't mention it, follow up to `MAX_LINKS_TO_FOLLOW` (3) menu links to find a page that does. If *no* page mentions happy hour → `ScraperRun(happy_hour_not_found)`, flag for investigation, **Claude is never called**.
3. Only pages that mention happy hour are sent to Claude (`HappyHourExtractor`).
4. Found → `HappyHourPersister` creates pending records, `ScraperRun(happy_hour_found)`, venue `scraped_found`, clears investigation.
5. Mentioned but unparseable → `ScraperRun(happy_hour_not_found)`, venue `scraped_not_found` + `needs_investigation`. No `HappyHour` created.

Every run logs a `ScraperRun` with `raw_data: jsonb`.

### Jobs (ActiveJob on Sidekiq, queue `:scrapers`)
- **`VenueDiscoveryJob`** `perform(lat:, lng:, radius:, neighborhood_id:)` → runs discovery, enqueues a `HappyHourScrapeJob` per new venue.
- **`HappyHourScrapeJob`** `perform(venue_id)` → runs `HappyHourScraper` for one venue.

Scheduling is via `sidekiq-cron` in `config/sidekiq_schedule.yml` — **all entries ship commented out**, so starting Sidekiq never auto-runs a scrape. The LLM step uses `claude-opus-4-8` with streaming for long menu content.

---

## Admin Dashboard (`/admin`)

Custom namespace — no admin gem. The approval workflow has too much domain-specific logic.

Key views:
- `admin/dashboard` — overview counts
- `admin/happy_hours#index` — pending approval queue
- `admin/venues#index` — `needs_investigation: true` venues
- `admin/comments#index` — flagged comments
- `admin/reports#index` — user-submitted reports

---

## Testing Guidelines

- **Write specs first.** TDD is the workflow, not an afterthought.
- Model specs: validations, scopes, associations, enum values, `discard` behavior
- Request specs: all `api/v1` endpoints — happy path + auth failures + validation errors
- System specs (Capybara): key web flows — approval queue, browsing happy hours by day
- Stub all HTTP with WebMock — never hit real APIs in tests
- Use FactoryBot for all test data. No raw `Model.create` in specs.
- Aim for meaningful coverage of behavior, not 100% line coverage for its own sake.

---

## Key Rails Conventions to Follow

- `app/models/concerns/` for shared model behavior (e.g., `Approvable`, `Statusable`)
- `app/controllers/concerns/` for shared controller behavior (e.g., `ApiAuthentication`)
- Named routes, resourceful controllers — avoid custom route names unless truly necessary
- `I18n` for user-facing strings in flash messages and emails
- Strong parameters in every controller action that accepts input
- Database indexes on every foreign key and every column used in a `where` clause
