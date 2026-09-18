# EVA private-chat integration: start and demonstrate it

## What this is

This is an opt-in demo, separate from the team's default `docker-compose.yaml`.
`Start-Demo.ps1` explicitly selects `docker-compose.integration.yaml`.
The tested local integration started from the commits in [BASELINE.md](BASELINE.md).
Its historical verification is in [TEST-RESULTS.md](TEST-RESULTS.md); publication
dependencies and limits are in [PUBLICATION.md](PUBLICATION.md).

**Do not assume all needed code is merged or published.** In particular, the
source-build Storage Dockerfile/project-reference adjustments are still local
and need Zein's review. This PR does not publish or change Storage-Service.
An unchanged GitHub main checkout is NOT sufficient for this demo yet.

No original checkout, original Docker volume, browser key, or historical database row was reset.
The school Supabase project remains shared; the Docker isolation does not isolate that database.

## The simple flow

```text
Sender's browser encrypts
  -> Gateway checks who is logged in and publishes
  -> storage_queue
  -> Zein's Storage creates/reuses the private room and saves ciphertext
  -> delivery_queue (only AFTER a successful save)
  -> Delivery checks Redis presence
  -> gateway:delivery
  -> Gateway sends the existing event to the recipient's browser
  -> Recipient's browser decrypts and displays
```

If the recipient is offline, the saved database message is loaded when they return.
RabbitMQ is a durable work queue, not the chat-history database. Delivery never writes to Supabase.
Redis Pub/Sub is best-effort live delivery, not proof the browser displayed a message.

## Requirements and repository layout

- Docker Desktop running Linux containers, with access to Docker Hub/Microsoft images and NuGet/npm.
- The matching integration versions of these sibling folders:

```text
integration/
  Contracts/
  Gateway/
  Delivery-Service/
  Storage-Service/
  UserService/
  Frontend/chat-app/
  Docker/                 <- run commands here
```

- A school/demo Supabase project, never production credentials.
- `profiles`, `rooms`, `room_members`, `messages.receiver_id`, and
  `get_or_create_private_room(p_sender_id, p_target_id)` from Zein's Storage migrations.
- Authenticated readers must be restricted by RLS to their own conversations.
- Backend secret only in UserService/Storage. Gateway history uses the publishable key plus the caller's token.
- Frontend uses Node 24 / Expo 57, `npm ci`, and the tracked package-lock.json.
  .NET builds run inside the SDK 8 image; no private NuGet token is needed.

The existing school project passed the room/history/access tests. **No shared migration was applied.**
For another database, first run `../Storage-Service/Database/Tests/Run-MigrationTest.ps1` locally,
then have the database owner review missing migrations and RLS. Never blindly reset/reapply the shared database.
Old messages with unknown recipients are not assigned invented recipients or exposed through private history.

## Start

1. Copy `.env.example` to a private `.env` with an editor. Set the three Supabase values and a local
   RabbitMQ username/password. Never commit that file or put the secret key in an `EXPO_PUBLIC_*` setting.
2. From this Docker directory run:

```powershell
.\Start-Demo.ps1
```

On Siar's PC only, the existing private .env can be reused without modifying it:

```powershell
.\Start-Demo.ps1 -EnvironmentFile ..\..\Docker\.env -UseExistingLocalBrokerCredential
```

That optional switch reads the old LOCAL broker credential into memory, never prints it,
and makes no change to the old broker. It is unnecessary when the new `.env` contains `RMQ_PASS`.
For subsequent starts without rebuilding, add `-NoBuild`.

- Chat: **http://localhost:18081**
- Gateway health: http://localhost:18080/health
- RabbitMQ management: http://localhost:18072 (the local broker credentials from .env)
- Storage and Delivery have no public HTTP ports.
- Project/network/volume names start with `eva-integration`; the original `docker` project remains separate.
- `rabbitmq-init` is a one-shot topology import, **not another application service**. Exit 0 is expected.

The RabbitMQ import runs after first boot, so RabbitMQ creates its configured login user before loading
the credential-free topology. Boot-time definition import suppresses that default-user creation:
[RabbitMQ documentation](https://www.rabbitmq.com/docs/access-control#default-state).
Do not mount the old `Gateway/rabbitmq.conf` boot-import configuration in this isolated stack.
Traefik watches only this Compose project and uses a distinct entrypoint to avoid changing old routes.

## Two-user demonstration

1. Use two separate browser profiles at **the exact same URL**, http://localhost:18081.
2. Use two newly registered, confirmed demo accounts. Each logs in once to publish its browser public key.
3. Select each other in the user list. Send a message each way. Both must reach the opposite screen.
4. Refresh both pages, select each other again: both sent and received messages must reappear once.
5. Close B's chat tab. Send from A. Reopen B in the SAME browser profile and select A: history restores it.
6. A third account must not see A/B's private conversation.

**Keys belong to the browser profile AND origin.** Old keys at localhost:8081 are not automatically
available at localhost:18081 (nor at 127.0.0.1). They have not been deleted.
An existing account whose key lives elsewhere will show a warning; use its original browser/origin
or a fresh demo account. Do not clear IndexedDB, reset keys, or expect incognito sessions to retain keys.
Key recovery/multiple devices remain out of scope.

One active chat tab per user is supported. A new tab replaces the old one with close code 4001.
The old tab displays a message and does not keep reconnecting.

## What the message labels mean

- `Wird gesendet`: waiting for Gateway's response.
- `An Warteschlange übergeben`: publishing succeeded; NOT a storage/delivery/read receipt.
- `Gespeichert`: this copy was loaded from database history (or received via the post-storage path).
- `Versand nicht bestätigt`: timeout/disconnection/error; outcome may be uncertain. Do not blindly resend.

Gateway replies include the client request ID, server message ID and timestamp.
History and live messages merge by server ID; the same ciphertext also resolves a lost-ack optimistic copy.
No automatic resend creates duplicate messages after a reconnect.

History: `GET /api/chat/history/{otherUserId}?limit=50&before=<cursor>` with the user's Bearer token.
Response: `{ messages: ChatMessageEvent[], nextCursor: string | null }`.
Pages are chronological; cursor ordering uses timestamp plus message ID; limit is 1..100.
The UI loads 50 initially, offers older messages, and refreshes history on reconnect/selection.

## Existing contract and encryption

No new RabbitMQ event was invented. `ChatMessageEvent` still has messageId, senderId, targetId,
ciphertext, timestamp. `ciphertext` contains the existing EncryptedPayloadV1 JSON:
version, senderId, recipientId, senderKeyId, recipientKeyId, iv, ciphertext.
Storage assigns room_id internally; it is not a target user ID and need not be supplied by the browser.
Gateway forwards these actual fields unchanged instead of fabricating encryption metadata.
The existing P-256 ECDH / AES-GCM scheme is retained. It is NOT a newly implemented signature/key-recovery system.
There is no separate digital-signature or wrapped-key field in this MVP contract.

RabbitMQ prefetch and MassTransit consumer concurrency both match the configured worker count (default 3).
The existing bounded WorkerPool is reused. MassTransit owns ACK/retry handling; no extra ACK semaphore was added.
There is a **per-WebSocket send lock** because a publish reply and incoming Redis message may send concurrently.
This protects the socket, not the RabbitMQ queue; .NET permits one concurrent send per socket:
[WebSocket.SendAsync](https://learn.microsoft.com/en-us/dotnet/api/system.net.websockets.websocket.sendasync).

## Tests

From the integration root, with Docker:

```powershell
docker run --rm -v "${PWD}:/src" -w /src mcr.microsoft.com/dotnet/sdk:8.0 sh -c 'dotnet test Gateway/Tests/Tests.csproj && dotnet test Delivery-Service/Delivery-Service.Tests/Delivery-Service.Tests.csproj && dotnet test Storage-Service/Storage-Service.Tests/Storage-Service.Tests.csproj'
.\Storage-Service\Database\Tests\Run-MigrationTest.ps1
```

From Frontend/chat-app with Node 24:

```powershell
npm ci
npm run typecheck
npm run lint
npm test
npx playwright install chromium
$env:EVA_E2E_ENV_FILE = (Resolve-Path ..\..\Docker\.env).Path
$env:EVA_E2E_PROJECT_HOST = 'your-confirmed-demo-project.supabase.co'
$env:EVA_ALLOW_TEST_WRITES = '1'
npm run test:e2e
```

The browser test creates three disposable demo accounts, tests real encryption/history/access control,
temporarily pauses Storage and stops/restarts the isolated broker/cache, then deletes only its fixtures.
It never purges queues or resets a database. Do not run it during someone else's use of this isolated demo.
It is skipped unless explicitly enabled and the environment's project hostname matches your confirmation.
Do not enable traces/videos: login responses contain tokens. Screenshots are local ignored test artifacts.

See [TEST-RESULTS.md](TEST-RESULTS.md) for the actual results and limitations.

## Stop / rollback

```powershell
.\Stop-Demo.ps1
```

Stops only `eva-integration` containers. It does not remove containers/volumes or touch the old stack.
Do not run `down -v`, prune, reset, or queue-purge commands to fix startup problems.
Use your original repositories/URLs to return to the preserved setup.

## Team handoff

- **Gateway:** review history/auth filtering, actual event forwarding, correlated acknowledgements, socket replacement.
- **Storage/Zein:** review integration of his existing private-room/save-then-send code and bounded shutdown settings.
  No redesign or shared schema migration was performed.
- **Frontend:** review key-preservation warnings, own-message decryption, history merge, lockfile/build repair.
- **Contracts:** confirm the existing five-field ChatMessageEvent remains the MVP contract; all services build
  against the same sibling source. Do not mix older private-package binaries into this demonstration.
- **Docker:** review the source build, topology bootstrap, private worker networks and environment template.
- Remaining publication dependency: Zein must review/publish the Storage source-build adjustments
  before a teammate can reproduce this exact demo using only remote branches.
- Keep the 14 moderate npm audit findings visible; no high/critical findings were reported in this run.
  Do not use `npm audit fix --force`: its suggested major changes/downgrades conflict with the agreed Expo baseline.
