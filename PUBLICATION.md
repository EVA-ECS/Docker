# Publication / review status — 18 September 2026

## This PR is an opt-in demo, not a default-stack replacement

The team's `docker-compose.yaml` is kept identical to the reviewed `origin/dev`
snapshot `0521ec4`. The isolated worker/chat demo is in
`docker-compose.integration.yaml`, selected explicitly by `Start-Demo.ps1`.
It has separate project names, networks, volumes and loopback ports. No stack is
restarted by publishing this PR, and no database migration is applied.

## Required service changes

| Repository | Review branch / PR | Requirement |
| --- | --- | --- |
| Delivery-Service | `feature/delivery-service-implementation`, PR 5 | Bounded workers, matching presence prefix, controlled shutdown |
| Gateway | `feature/delivery-mvp-alignment-dev`, PR 11 | Live receive, history endpoint, public-key routes, sibling Contracts source build |
| Contracts | `feature/delivery-service-implementation`, PR 11 | Existing five-field ChatMessageEvent; encrypted envelope semantics |
| Frontend | `feature/private-chat-history-integration`, separate PR to dev | Receiving/decryption, persisted history, Node 24 and lockfile |
| Storage-Service | Zein's `feature/storage-service-simple`, PRs 8/10 | Existing automatic private rooms and save-before-forward flow |
| UserService | Existing `main` at `0e25e3dcb1cda3dfbf01918e63e9181923ea6afd` | Existing auth and public-key endpoints; no application changes |

**Outstanding prerequisite:** Zein's currently published Storage Dockerfile builds
from the service directory and uses a private Contracts package. The tested
integration uses a parent-context Dockerfile and a sibling Contracts project
reference instead. Those Storage changes are still local and are deliberately
NOT published by this Docker PR. Coordinate with Zein before attempting a fresh
remote-only checkout of the opt-in demo. Do not substitute old images or assume
that healthy containers prove this dependency is satisfied.

The local Storage integration also includes bounded worker validation, HTTP/
shutdown timeouts and save-before-forward tests. Their review/publication remains
with the Storage owner. No group-chat or new storage architecture is introduced.

## Evidence and limits

`TEST-RESULTS.md`, `BASELINE.md` and `CHANGED-FILES.md` describe the earlier full
local integration, including changes outside this PR. They are not a claim that
all dependencies have been merged or that GitHub main reproduces the demo.

For this publication the source builds, scoped unit tests and Compose syntax are
checked again. No shared Supabase records or schemas are changed during publishing.
Use only school/demo credentials in a private `.env`. Never commit tokens or reuse
production credentials. The optional original-broker compatibility switch reads
an existing LOCAL credential only into memory; normal setup does not require it.
