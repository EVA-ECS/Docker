# Verification — 2026-09-18

Historical results for the full local integration, not a claim that every
dependency below is already available on GitHub. See [PUBLICATION.md](PUBLICATION.md)
for the staged publication and its outstanding Storage dependency.

## Baseline

Unchanged GitHub main Frontend Docker build: **failed as reproduced**, `EJSONPARSE`, committed merge markers
in package.json. Four conflicted files were restored from the reviewed merged dev source before integration.
Exact main and reused source commits are in [BASELINE.md](BASELINE.md).

## Implemented integration

| Check | Result |
| --- | --- |
| Docker source builds: Frontend, Gateway, UserService, Storage, Delivery | Passed |
| Frontend clean `npm ci` and Expo web export | Passed |
| Frontend TypeScript and ESLint | Passed, no reported errors/warnings |
| Frontend encryption/history unit tests | 5 passed |
| Gateway history/auth/acknowledgement/socket tests | 13 passed |
| Delivery routing/pool/cancellation/consumer-completion tests | 15 passed |
| Storage mapping/store/pool/save-before-forward tests | 9 passed |
| Zein's older opt-in FrontendToDelivery .NET test | 1 skipped; not counted as passed |
| Zein's migrations, applied twice to temporary PostgreSQL 17 | Passed |
| Concurrent private-room creation using two PostgreSQL clients | Passed, exactly one private room |
| Real Chromium multi-user application scenario | Passed, including recipient-screen assertions |
| Storage and Delivery container shutdown | Both exit code 0, no OOM; restarted successfully |
| Broker queues after browser test | No ready/unacknowledged messages; one consumer per service |
| Live RabbitMQ channel inspection | Storage and Delivery both have prefetch 3; no outstanding acknowledgements |
| npm audit --omit=dev | 14 moderate findings; 0 high, 0 critical; not silently fixed with major downgrades |

**42 unit tests passed**, plus the database migration/concurrency checks and the full browser scenario.
The final rebuilt stack repeated the extended browser scenario successfully in 50.7 seconds.
The first repeat of Delivery unit tests incorrectly used `--no-restore` in a fresh SDK container;
that container had no NuGet package cache. Rerunning with normal restore passed all 15 tests without that error.

## Browser scenario (real school/demo Supabase + isolated Docker services)

The Playwright test in Frontend/chat-app/tests/e2e/private-chat.spec.ts:

1. Creates three unique confirmed demo accounts and logs in through the real UI.
2. Publishes each browser's public key through the existing authenticated UserService route.
3. Sends concurrent first messages in both directions; both recipient screens display plaintext after decryption.
4. Confirms two stored ciphertext rows with receiver IDs and one automatic private room.
5. Reloads both pages: own sent messages and received messages reappear once, with saved status.
6. Confirms the outsider cannot read the A/B messages via either Gateway or direct Supabase REST with its token;
   unauthenticated Gateway history returns 401.
7. Pages history using limit=1 and an opaque cursor; no duplicates, correct end-of-history.
8. Closes Bob's page, sends while offline, reopens it with the same browser key: history restores the message.
9. Pauses only isolated Storage: publishing is acknowledged, but no database row or recipient message appears
   before Storage resumes. After resuming, the recipient receives the saved message.
10. Stops only the isolated RabbitMQ: the UI reports unconfirmed publishing. Restarts it and verifies publishing/live delivery recover.
11. Stops only isolated Redis: the message still reaches persistent storage; after recovery, history restores it.
12. Tampers with one test ciphertext, observes an understandable decryption error, then restores the exact test row.
13. Opens a replacement tab: the old tab gets the replacement notice and stops reconnecting; new-tab delivery works.
14. Logs the same account into an empty browser context: missing-key warning appears; the published key is not replaced.
15. Closes the test contexts and deletes only this run's messages, private rooms/memberships, profiles, and Auth users.

Screenshots after delivery are local ignored artifacts:
`Frontend/chat-app/test-results/private-chat-alice.png` and `private-chat-bob.png`.
Login traces/videos are disabled to avoid recording tokens. Existing browser storage was never cleared.

## Problems found during verification and corrected

- Main's committed merge markers prevented a fresh Frontend build.
- Main's root .gitignore hid package-lock.json: fixed so the reproducible lockfile can be committed.
- Private NuGet package dependencies were replaced by the agreed sibling Contracts source references.
- Fresh RabbitMQ imported topology but had **no login users**. Changed to post-boot one-shot topology import,
  after default credential initialization. The isolated services then connected successfully.
- Gateway publish responses and live messages needed correlated IDs and actual encryption fields.
- Own sent history needed ECDH decryption using the recipient's public key.
- A fresh browser used to be able to replace an existing key: it now stops with a warning.
- Multiple tabs needed an explicit replacement close status instead of an endless reconnect competition.
- Gateway publishing now has a 10-second cancellation bound during broker failure.
- Delivery's Worker SDK included nested test output as content; excluded it to avoid recursive copied output.
- The first browser test fixture cleanup hit the demo schema's profile/Auth foreign key: cleanup now removes
  only the recorded fixture profiles before their Auth users. Those first failed-run fixtures were also cleaned up.

## Preservation and limits

- Original repositories and their existing dirty Frontend files are not modified. All feature edits are under integration/.
- Original `docker` project containers and volumes remain available. No `down -v`, reset, queue purge, or prune was used.
- The shared Supabase schema was not changed. Checks used its API surface and actual RLS behavior, not a privileged SQL policy dump.
- Only disposable test fixtures were created/deleted in the school database. Those fixtures are intentionally not recoverable;
  historical/team records were preserved.
- Live Pub/Sub delivery is not durable or a client receipt. History is the fallback. No new read-receipt/outbox/recovery system was added.
- Shutdown checks cover a real quiescent stop plus unit cancellation while processing; no power-loss durability guarantee is claimed.
- Existing encryption is preserved, not redesigned or independently security-audited. Groups and multi-device key recovery remain excluded.
- Container base image tags remain upstream tags. The source snapshot and npm lock are recorded; rebuilds can pick up newer base-image patches.
- The npm audit findings need a separate Expo-compatible dependency review before production use.
- No commit, push, merge, or PR was performed. Teammates cannot clone these local changes until coordinated publication is approved.

## Running it again

See [DEMO.md](DEMO.md) for startup, prerequisites, commands and the browser-test opt-in safety checks.
Do not use the legacy test that merely stops at delivery_queue as a substitute for the new recipient-screen scenario.
