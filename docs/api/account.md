# Account data — export and deletion (15.2 / 15.3)

QUESTIONS #17, #18, #45.

- `POST /api/v1/me/export` (auth, `throttle:3,60`) → `202 {email}`: queues
  `SendDataExport`, which mails a ZIP (`nardarena-data.zip`) to the
  account e-mail in the player's language. One JSON file per section:
  `profile`, `matches`, and every table holding the player's rows
  (`App\Services\AccountExport::TABLES`). Push tokens, hashes and
  idempotency keys are left out; cheat flags stay internal.
  No e-mail (guest) → `409 {code: "email_required"}`: the client asks the
  player to link an e-mail first (17.2 flow upgrades the guest in place).
- `DELETE /api/v1/me` → `{ok, deletesAt}`: starts the 30-day grace and
  revokes every token; signing in again cancels it; `accounts:purge`
  (daily 03:30) deletes accounts past the grace.
- Web page `GET /delete-account` (Google Play requirement, not under
  `/api`): e-mail → `POST /delete-account/code` (`throttle:5,10`, mails a
  `deletion` code only when a non-guest account uses the address, same
  answer otherwise, never creates an account) → `POST
  /delete-account/confirm` (`throttle:20,1`) → same grace as `DELETE /me`.
  Language: `?lang=az|en|ru|tr`, else the browser language, else `az`.
