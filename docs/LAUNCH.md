# Launch plan

Owner-facing checklist for going live. Store texts and the owner checklist
in detail: `docs/store/listing.md` (§8). Decisions are dated; open items
are unchecked.

## Decisions

- 2026-10-30 — Store accounts (Google Play, Apple) are opened as
  **individual (personal) accounts** in the owner's name (owner's choice
  after comparing; first answer was "company", changed the same day).
  Consequences: no D-U-N-S needed; Apple shows the owner's legal name as
  the seller; Google may show the owner's address on a monetised listing;
  income is personal; **new personal Google Play accounts must run a closed
  test with at least 12 opted-in testers for 14 days before production
  access** — recruit testers early. Moving the apps to a company account
  later is possible (app transfer) but takes work.

## Steps (critical path first)

### 1. Identity and accounts (start first — longest waits)
- [ ] Google Play Console personal account (one-time $25, ID verification)
- [ ] Apple Developer Program individual enrolment ($99/year, ID check)
- [ ] 12+ testers (Gmail accounts, Android phones) lined up for Google's
      14-day closed test
- [ ] App name trademark / store availability check ("NardArena")
- [ ] Final bundle / application id (now `com.nardarena.app`; fixed after
      the first upload)

### 2. Infrastructure
- [ ] Domain (API, game server, support mailbox, privacy and deletion pages)
- [ ] Hosting: Kubernetes with the Helm chart (`infra/helm/nardarena`) or a
      single VM with docker compose to start; managed MySQL 8.4 + Redis
- [ ] Transactional e-mail provider (sign-in codes, data export)
- [ ] Firebase project (FCM) + Apple APNs key (push, ADR-041)
- [ ] Optional: Sentry DSN (code ready, ADR-043)

### 3. Store material
- [ ] Privacy policy page (content: `docs/store/listing.md` §7)
- [ ] App icon, feature graphic, screenshots (we can capture them)
- [ ] Store texts (drafts in az/en/ru/tr ready) and content rating forms

### 4. Purchases and sign-in
- [ ] Yaqut products in both stores (500 / 1 200 / 2 600), tax and banking
      forms, Apple paid-apps agreement
- [ ] Apple / Google sign-in keys (code ready, disabled by config)

### 5. Test and release
- [ ] Google Play internal / closed test, iOS TestFlight (iOS build needs a
      Mac or a cloud macOS build service)
- [ ] Store review, staged rollout
