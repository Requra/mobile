You are helping me build the real-time audio calling feature inside an existing Flutter app.

## Current State
- The Flutter app already has a fully built UI for meetings (lobby, meeting screen, participant list, invitations, recordings, etc.).
- All backend REST APIs are already implemented and wired into the app: creating/listing/updating meetings, invitations (member + guest), join/leave meeting, start/end meeting, participants management, consent, and a chunked audio recording upload flow (local recording is captured on-device and uploaded in chunks to the backend via `POST /api/recordings/{recordingId}/chunks`, finalized via `POST /api/recordings/{recordingId}/stop`).
- The backend also exposes (or will expose) `POST /api/meetings/{meetingId}/agora-token`, which returns `{ appId, channelName, uid, token, role, expiresAt }` for Agora authentication.
- The ONLY missing piece is integrating the actual real-time audio calling using the `agora_rtc_engine` Flutter package (https://pub.dev/packages/agora_rtc_engine). Nothing else needs to be built from scratch — this is purely about wiring Agora into the existing screens and existing API calls.

## What I need from you
Produce a detailed, step-by-step **implementation plan** (not the full code, a plan I can execute against or hand to a coding agent) covering:

1. **Package setup**: `agora_rtc_engine` installation, required platform permissions (iOS Info.plist, Android manifest) for microphone access, and any platform-specific setup gotchas.

2. **Engine lifecycle management**: where/how to initialize `RtcEngine` (using the `appId` returned from the token endpoint), and how to properly dispose it when leaving a meeting, including handling app backgrounding/foregrounding on both iOS and Android.

3. **Join/Leave flow integration**: how to wire the Agora `joinChannel` call into the existing `POST /api/meetings/{meetingId}/join` flow — i.e., sequence: call join API → call agora-token API → join Agora channel with returned token/channelName/uid → update UI state. Same for leave: leave Agora channel → call `POST /api/meetings/{meetingId}/leave`.

4. **Token renewal**: how to listen for Agora's `onTokenPrivilegeWillExpire` callback and re-fetch a fresh token from `POST /api/meetings/{meetingId}/agora-token` to renew via `renewToken()` without dropping the call.

5. **Participant state sync**: how to reconcile Agora's own participant events (`onUserJoined`, `onUserOffline`, mute state callbacks) with the backend's participant state from `GET /api/meetings/{meetingId}/participants`, so the UI reflects a single source of truth (avoid double state / race conditions between Agora events and API polling).

6. **Mute/unmute, speaker toggle, and host controls**: how to implement local mute, and how a HOST can remove a participant (already backed by `DELETE /api/meetings/{meetingId}/participants/{participantId}`) while also forcing that user off the Agora channel.

7. **Local audio recording integration**: since audio is already being captured and chunk-uploaded independently of Agora (via the existing recording endpoints), clarify the cleanest way to capture the mixed/local audio stream during an active Agora call for this recording pipeline — e.g., using Agora's `AudioFrameObserver` to tap raw PCM frames versus using a separate native audio recorder — and how to keep this in sync with meeting start/stop and Agora join/leave without conflicts.

8. **Error handling & reconnection**: how to handle Agora connection state changes (`onConnectionStateChanged`), network loss/reconnect during a call, and what should happen to the meeting/recording state in each case.

9. **State management approach**: recommend how to structure this within the app's existing state management (assume Provider/Riverpod/Bloc — ask me which one my app uses if it matters, otherwise give a pattern that fits any of them).

10. **Testing plan**: a short list of manual test scenarios to validate the integration (join/leave, token expiry mid-call, host removing a participant, backgrounding, network drop, concurrent recording).

Please give me the plan as clearly ordered, actionable steps/phases — I'll be executing or delegating this plan afterward, so it should be concrete enough to turn directly into tasks.
