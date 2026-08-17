You are helping me plan the implementation of a ClickUp integration feature inside an existing Flutter app (project management app called Requra).

## Current State
- The Flutter app already has a working UI shell and networking layer wired to a backend that follows a consistent response envelope: `{ isSuccess, statusCode, message, data, errors }`.
- The backend exposes (or will expose) a set of ClickUp integration endpoints, documented below.
- This is a **project-scoped** integration: each Requra "project" (identified by `projectId`) can optionally be connected to a ClickUp Workspace/Space/List, and "approved user stories" within that project can be pushed to ClickUp as tasks.

## Known API Contract (confirmed)

1. `GET /api/ClickUp/auth/authorize?projectId={projectId}` → returns `{ authUrl, projectId }`. The app must open `authUrl` in a WebView for the user to log in/consent on ClickUp's site.
2. `POST /api/ClickUp/auth/callback` with `{ code, projectId }` → completes the OAuth exchange server-side. Returns `{ isSuccess }` only (no data).
   ⚠️ **Open question, not yet resolved with backend**: how the mobile app actually receives the `code` after the ClickUp consent screen (deep link interception vs. the backend handling the whole exchange without app involvement). Build the OAuth screen so this is an isolated, swappable piece — don't hardcode assumptions about the exact redirect mechanism until backend confirms. -- make it by deep link -- and that is confirmed
3. `GET /api/ClickUp/status/{projectId}` → returns `{ isConnected, teamId, spaceId, listId, tokenExpired, expiresAt }`.
4. `POST /api/ClickUp/disconnect/{projectId}` → disconnects, no data.
5. `POST /api/ClickUp/push/{projectId}/approved` → bulk-pushes all approved user stories to ClickUp, returns per-story results (`createdCount`, `updatedCount`, `failedCount`, `skippedCount`, `totalCount`, `details[]` with per-story `userStoryId`, `clickUpTaskId`, `action`, `success`, `message`).
6. Standard error shape: `{ isSuccess: false, statusCode, message, data: null, errors: [...] }`.

## Confirmed Backend Decisions
- **OAuth redirect**: `redirect_uri` will resolve to a mobile deep link (`requra://clickup/callback`) that the app intercepts from inside the WebView, extracts `code` + `state` (=`projectId`) from, then calls `POST /api/ClickUp/auth/callback` with. No picker/selection screen needed for this part — it's a pure WebView + deep-link-interception flow.
- **Workspace/Space/List selection is fully automatic, backend-side, no user picker needed**: the backend auto-selects the first Workspace (Team) returned for the authenticated ClickUp user, then the first Space within it, then the first List within that Space. These resolved IDs come back in `GET /status/{projectId}` as `teamId`/`spaceId`/`listId`. **There is no endpoint to list or change these** — the mobile app has no picker UI to build for this.
  - ⚠️ Known gap to design around: `GET /status/{projectId}` currently only returns raw IDs, not human-readable names (no `teamName`/`spaceName`/`listName`). Until/unless the backend adds those, the "Connected" screen can only display the IDs as-is (or omit them and just show a generic "Connected ✓" state) — don't design a UI that assumes friendly names will be available, but structure the display so names can be added later as a one-line change if the backend adds them.
  - ⚠️ Unresolved edge case: it's not yet confirmed what happens if the auto-selected Space has zero Lists inside it (would the connect flow or a subsequent push simply fail?). Build defensive error handling around the push flow for this rather than assuming it can't happen.

## What I need from you
Produce a detailed, step-by-step **implementation plan** (not full code — a plan concrete enough to execute against or hand to a coding agent) covering:

1. **Feature architecture**: how to structure this as a self-contained module in the app (screens, state management, repository/service layer for the ClickUp API calls), assuming the rest of the app already has an established networking + state pattern (ask me which state management library if it matters, otherwise give a pattern that fits Provider/Riverpod/Bloc generically).

2. **Connection flow UI**: screens/states needed — "Not Connected" (with a Connect button), "Connecting" (WebView that intercepts the `requra://clickup/callback` deep link, extracts `code`+`state`, then calls the callback endpoint), "Connected" (showing whatever connection info is available — see the naming gap noted above — a Disconnect button, and a Push button), and "Token Expired" (prompting reconnect). Since Workspace/Space/List selection is fully automatic server-side, there is no picker screen in this flow — design it as a straight 3-state pipeline (Not Connected → Connecting → Connected), not a multi-step wizard.

3. **State polling / refresh strategy**: when to call `GET /status/{projectId}` — on screen entry, after returning from the WebView, and any periodic re-check needed to catch `tokenExpired` transitions.

4. **Push flow UX**: triggering `POST /push/{projectId}/approved`, showing a progress/loading state, and then displaying the per-story results (`details[]`) in a meaningful way — e.g., a summary banner (X created, Y updated, Z failed) plus an expandable list showing which specific stories failed and why (`message` field), so the user can retry failed ones after fixing whatever caused the failure.

5. **Error handling**: mapping the standard error envelope (`errors[]`, `statusCode`) to user-facing messages, especially for the documented 401 "token expired/invalid" case — should surface a "reconnect" prompt rather than a generic error toast.

6. **Local caching strategy**: what (if anything) should be cached locally (e.g., last known connection status) vs. always fetched fresh, to avoid a flash of "not connected" UI on every screen load while `GET /status` is in flight.

7. **Testing plan**: manual test scenarios to validate (fresh connect, reconnect after token expiry, disconnect, bulk push with mixed success/failure results, network failure mid-OAuth, backgrounding the app during the WebView flow).

Please give me the plan as clearly ordered, actionable phases/steps — I'll be executing or delegating this plan afterward, so it should be concrete enough to turn directly into tasks.
