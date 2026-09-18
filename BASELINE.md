# Integration baseline — 2026-09-18

Historical local integration record, before the staged publication. See
[PUBLICATION.md](PUBLICATION.md) for the current PR dependencies and limits.

Separate Git worktrees, branch `feature/reproducible-private-chat`, based on GitHub main.
Original worktrees, uncommitted Frontend files, containers and persistent volumes remain untouched.

| Repository | main commit |
| --- | --- |
| Contracts | 52a9af9928a4080b04fbb434f0bd4522c57c1fdc |
| Delivery-Service | b8af093633d6834e53ac601377dbdd6293f4e57a |
| Gateway | 04b5eece97a93474681a7d0d27f3c2fd3aa62808 |
| Docker | c9a681e3d56777184450e9af46a03a749c5c3512 |
| Storage-Service | 9c49f6a88368c510e7acf8ed9d5dcefb4642367c |
| Frontend | b536efdc70bc464c301d732d656f7761c804c83c |
| UserService | 0e25e3dcb1cda3dfbf01918e63e9181923ea6afd |
| Main-Database | 264920cd00f4905ed2f645d94dbb653e539858ed |

## Unchanged baseline reproduction

Ran `docker build --progress=plain -t eva-main-baseline-frontend:20260918 .` in Frontend/chat-app before editing.
Result: exit 1 at `RUN npm i`: `EJSONPARSE: Merge conflict detected in your package.json.`
Four frontend files contain unresolved markers. main does not provide a buildable frontend.

Other source-confirmed gaps: Compose comments out workers; Storage/Delivery main are templates;
RabbitMQ imported definitions use fanout/dotted queues, but services expect topic/underscored queues.
The old running local stack is not this baseline (images from August/early September).

## Reused code (not rewritten)

- Contracts 49217ed2a05531675e3d95fa13a9a0777a4b1ee2, PR 11.
- Delivery 8c3f5b69edd44ede62dc17a83fdf987ca4293cdd, PR 5.
- Gateway 327e932e6383c3eec11092587b5fce64e0c07f26, PR 11 (delivery files only; preserve public-key routes).
- Storage ce3ad776eb613378f8d656c54d29757d092de1c8, Zein's PR 8/10.
- Frontend a8451a6f9ff29856bd4abfae0c294d6e15a10226, merged dev versions of conflict-marked files.

Two unused obsolete frontend Supabase/gateway helpers from main are removed only in the integration copy.
No groups, no new RabbitMQ event type. Ciphertext remains serialized EncryptedPayloadV1 JSON.
SDK 57 requires Node >=22.13, so the frontend build now uses Node 24 and a lockfile.
Backend services reference the same sibling Contracts project, avoiding private NuGet build credentials.
