# AppyHour — Mobile App

Expo 56 · React Native · TypeScript · Expo Router

Consumes the Rails `api/v1` REST API. Does not render any server-side HTML.

---

## API

**Base URL:**
- Development: `http://localhost:3000/api/v1`
- Production: TBD

All authenticated requests require:
```
Authorization: Bearer <token>
Content-Type: application/json
```

Tokens are issued by `POST /api/v1/sessions` (login) and stored in Expo SecureStore.

---

## Key Screens / Routes

| Route | Screen |
|-------|--------|
| `/` | Browse happy hours (today, by neighborhood) |
| `/map` | Map view with nearby venues |
| `/venues/[id]` | Venue detail + happy hour list |
| `/submit` | Submit a venue or happy hour |
| `/favorites` | Saved venues |
| `/notifications` | In-app notification center |
| `/account` | Profile, settings |

---

## Stack

- **Expo 56** with Expo Router (file-based routing)
- **TypeScript** throughout
- **NativeWind** (Tailwind for React Native) for styling
- **Zustand** or **React Query** for state / server state (TBD)
- **Expo SecureStore** for token storage
- **Expo Notifications** for push notifications (when implemented)

---

## API Conventions

- All list endpoints are paginated: `{ data: [...], meta: { page, total_pages } }`
- Errors return: `{ error: "message" }` with appropriate HTTP status
- Authenticated endpoints return 401 if token missing/invalid

---

## Development

```bash
cd mobile
yarn install
expo start
```

For iOS simulator or Android emulator, the Rails API must be running at `localhost:3000`.
On a physical device, update the base URL to your machine's LAN IP.

---

## Testing

- Jest + React Native Testing Library for unit/component tests
- Detox for E2E (if needed later)
- Mock the `api/v1` HTTP layer in all unit tests — never hit the real API in tests
