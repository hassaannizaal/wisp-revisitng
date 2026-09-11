# WISP

A calm space for daily reflections. Flutter app + Express API, authenticated end-to-end with Firebase.

```
frontend/   Flutter app (Riverpod, go_router, Firebase Auth)
backend/    Express 5 API (firebase-admin, Firestore)
firebase/   Firestore rules, indexes and emulator config (Firebase CLI)
```

## How it works

1. The app signs the user in with **Firebase Auth** (email + password).
2. Every API call carries the user's **Firebase ID token** as `Authorization: Bearer <token>`.
3. The backend verifies the token with the Admin SDK and reads/writes **Firestore** on the user's behalf.
   Client SDKs never write to Firestore directly (see `firebase/firestore.rules`).

## Prerequisites

| Tool | Version | Notes |
| --- | --- | --- |
| Node.js | 20+ | backend |
| Flutter | 3.35+ (stable) | frontend — run `flutter doctor` |
| Firebase project | `wisp-mental-health-app` | Email/Password sign-in enabled under *Authentication → Sign-in method* |

## Backend

```bash
cd backend
cp .env.example .env          # optional, defaults are fine locally
npm ci
npm run dev                   # http://localhost:5000
```

Credentials are resolved in this order:

1. `backend/serviceAccountKey.json` — Firebase console → Project settings → Service accounts → *Generate new private key* (git-ignored).
2. Application Default Credentials — set `GOOGLE_APPLICATION_CREDENTIALS`, or rely on the runtime identity on Cloud Run / GCE.

Smoke test: `curl http://localhost:5000/health`

### API

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/health` | – | Liveness probe |
| GET | `/api/wisps/protected` | Bearer | Echoes the caller's uid/email (connection self-test) |
| GET | `/api/wisps?limit=20` | Bearer | The caller's wisps, newest first (max 100) |
| POST | `/api/wisps` | Bearer | Body `{ "mood": string ≤ 50, "reflection": string ≤ 2000 }` → `201 { wispId, wisp }` |

Errors are always JSON: `{ "error": "message", "details"?: [{ field, message }] }`.
Requests under `/api` are rate limited (100 per 15 min per IP by default) and bodies are capped at 16 KB.

```bash
npm test      # node:test + supertest, no Firebase needed
npm run lint  # eslint
```

## Frontend

```bash
cd frontend
cp .env.example .env          # API_BASE_URL — required: it is bundled as an asset
flutter pub get
flutter run -d chrome         # web is supported out of the box
```

`API_BASE_URL` per target:

| Target | Value |
| --- | --- |
| Chrome / Windows desktop | `http://localhost:5000/api` |
| Android emulator | `http://10.0.2.2:5000/api` |
| Physical device | `http://<your-LAN-IP>:5000/api` |

`firebase_options.dart` is configured for Android, iOS and web. Desktop targets need `flutterfire configure` first.

```bash
flutter analyze
flutter test
```

## Firebase (rules & indexes)

Deploy once per project, and again whenever `firebase/firestore.rules` or `firebase/firestore.indexes.json` change:

```bash
npm install -g firebase-tools
firebase login
cd firebase
firebase deploy --only firestore:rules,firestore:indexes
```

The `GET /api/wisps` query needs the composite index `(uid ASC, createdAt DESC)`; until it is deployed the endpoint answers `503`.

Local emulators (optional, needs Java 11+): `firebase emulators:start` from `firebase/`, then add
`FIRESTORE_EMULATOR_HOST=localhost:8080` and `FIREBASE_AUTH_EMULATOR_HOST=localhost:9099` to `backend/.env`.

## Production checklist

- `NODE_ENV=production`, `CORS_ORIGINS=<your web origin(s)>`, `TRUST_PROXY=1` behind a load balancer.
- Run the backend with Application Default Credentials instead of a key file.
- Deploy the Firestore rules and indexes above.
- Build the app with `flutter build web --release` (or the platform of your choice) with a production `.env`.
