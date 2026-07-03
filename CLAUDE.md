# AppyHour — Monorepo

Happy Hour tracking web and mobile app. Cleveland-focused initially, architected to be city-agnostic.

## Repository Structure

```
appy_hour/
├── web/      # Rails 8.1 — full-stack Hotwire/Tailwind app + REST api/v1 namespace
├── mobile/   # Expo 56 — React Native mobile app (consumes api/v1)
└── CLAUDE.md # This file
```

Each subdirectory has its own `CLAUDE.md` with stack-specific detail.

## Quick Start

### Web (Rails)
```bash
cd web
bundle install
rails db:create db:migrate
bin/dev
```

### Mobile (Expo)
```bash
cd mobile
yarn install
expo start
```

Rails must be running on `localhost:3000` for mobile dev.

---

## Core Architecture

The Rails app is **not** API-only. It serves:
1. **Web UI** via Hotwire (Turbo + Stimulus) + Tailwind at `/`
2. **REST API** under `api/v1` namespace for the Expo mobile app

Business logic lives in service objects (`app/services/`), not in controllers. This keeps both the web and API controllers thin and avoids duplication between the two response types.

---

## Full Model Map

```
Neighborhood        name, city, slug
Venue               name, address, city, zip_code, phone, website_url,
                    neighborhood_id, lonlat geography(Point,4326),
                    needs_investigation:bool, scraper_status:enum
HappyHour           venue_id, status:enum, submitted_by_id, approved_by_id, approved_at, notes
HappyHourDay        happy_hour_id, day_of_week:int(0-6), start_time, end_time, specific_date(nullable)
HappyHourGeneric    happy_hour_day_id, applies_to, discount_type:enum, discount_value, description, status:enum
HappyHourItem       happy_hour_day_id, name, category, original_price, happy_hour_price, description, status:enum
HappyHourBogo       happy_hour_day_id, buy_quantity, get_quantity, get_discount_type:enum,
                    get_discount_value(nullable), applies_to, item_name, description, status:enum
User                email, role:enum(user/editor/admin), [Devise fields]
FavoriteVenue       user_id, venue_id
Rating              rateable:polymorphic(Venue|HappyHour), user_id, value:int(1-5)
Comment             commentable:polymorphic(Venue|HappyHour), user_id, body, status:enum
Report              reportable:polymorphic, user_id, reason, notes, resolved_at
Notification        user_id, notification_type, channel:enum, subject:polymorphic, sent_at, read_at
ScraperRun          venue_id, run_at, result:enum, notes, raw_data:jsonb
```

---

## Status Enum

Shared across `HappyHour`, `HappyHourGeneric`, `HappyHourItem`, `HappyHourBogo`, `Comment`:

```
pending → approved → rejected → flagged → pending_deletion → deleted
```

- `pending` — newly submitted, awaiting review
- `approved` — live on site
- `rejected` — denied by admin/editor
- `flagged` — reported by users or scraper detected a change
- `pending_deletion` — soft-delete requested, awaiting approval
- `deleted` — soft-deleted and approved

---

## Roles (CanCanCan)

| Role   | Can Do |
|--------|--------|
| admin  | Everything. Auto-approves own submissions. Just the app owner. |
| editor | Approve/reject submissions. Auto-approves own submissions. |
| user   | Browse, favorite, rate, comment, submit venues/happy hours (needs approval). |

---

## Approval Workflow

ALL new `HappyHour` records require approval before going live:
- Admin/editor submissions → auto-approved on create
- User submissions → `status: pending`, queued in `/admin` approval dashboard
- Soft deletes → set to `pending_deletion`, also require admin/editor approval

The approval queue lives at `/admin` (custom namespace — not an admin gem).

---

## Location

PostGIS from day one. Venue has a `lonlat geography(Point, 4326)` column.
Radius queries use `ST_DWithin`. Neighborhood model for city/neighborhood filtering.
