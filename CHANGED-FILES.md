# Changed files in the isolated integration

Historical inventory of the local integration, not this Docker PR's file list.
See [PUBLICATION.md](PUBLICATION.md) for what is being published separately.

All paths below are relative to C:/Users/siyer/Desktop/EVA/integration/.
Comparison is against each recorded GitHub main commit, not against Siar's older feature branches.
Most Delivery/Storage/Contracts files are **reused existing work**, not newly invented implementations;
see BASELINE.md for their source commits. Nothing is committed or pushed.

Main-Database and the shared Supabase schema are unchanged. Original sibling checkouts are unchanged.
Deleted only in this integration copy: Delivery-Service/Worker.cs (template),
Frontend/chat-app/src/utils/gateway.ts and supabase.ts (unreferenced merge leftovers).

## Contracts

- `Contracts/EVA-ECS.Chat.Contracts/EVA-ECS.Chat.Contracts.csproj`
- `Contracts/EVA-ECS.Chat.Contracts/Events/ChatMessageEvent.cs`
- `Contracts/EVA-ECS.Chat.Contracts/Events/ChatMessagePublishedEvent.cs`
- `Contracts/EVA-ECS.Chat.Contracts/Messages/EncryptedMessagePayload.cs`
- `Contracts/EVA-ECS.Chat.Contracts/Requests/SendMessageRequest.cs`
- `Contracts/README.md`

## Delivery-Service

- `Delivery-Service/appsettings.json`
- `Delivery-Service/Configuration/DeliveryOptions.cs`
- `Delivery-Service/Configuration/RabbitMqOptions.cs`
- `Delivery-Service/Configuration/RedisOptions.cs`
- `Delivery-Service/Delivery-Service.csproj`
- `Delivery-Service/Delivery-Service.Tests/Delivery-Service.Tests.csproj`
- `Delivery-Service/Delivery-Service.Tests/DeliveryMessageProcessorTests.cs`
- `Delivery-Service/Delivery-Service.Tests/DeliveryWorkerPoolTests.cs`
- `Delivery-Service/Delivery-Service.Tests/QueueReceiverTests.cs`
- `Delivery-Service/Delivery-Service.Tests/RedisDeliveryRouterTests.cs`
- `Delivery-Service/Delivery-Service.Tests/TestMessageFactory.cs`
- `Delivery-Service/Delivery-Service.Tests/Usings.cs`
- `Delivery-Service/Dockerfile`
- `Delivery-Service/Dockerfile.dockerignore`
- `Delivery-Service/Documentation/first_commit.md`
- `Delivery-Service/Messaging/QueueReceiver.cs`
- `Delivery-Service/nuget.config`
- `Delivery-Service/Processing/DeliveryMessageProcessor.cs`
- `Delivery-Service/Processing/DeliveryWorker.cs`
- `Delivery-Service/Processing/DeliveryWorkerPool.cs`
- `Delivery-Service/Processing/IDeliveryMessageProcessor.cs`
- `Delivery-Service/Program.cs`
- `Delivery-Service/README.md`
- `Delivery-Service/Routing/IDeliveryRouter.cs`
- `Delivery-Service/Routing/IRedisGatewayStore.cs`
- `Delivery-Service/Routing/RedisDeliveryRouter.cs`
- `Delivery-Service/Routing/RedisGatewayStore.cs`
- `Delivery-Service/Worker.cs`

## Gateway

- `Gateway/Configuration/RedisRoutingOptions.cs`
- `Gateway/Controllers/ChatController.cs`
- `Gateway/Controllers/ChatHistoryController.cs`
- `Gateway/definitions.json`
- `Gateway/Dockerfile`
- `Gateway/Dockerfile.dockerignore`
- `Gateway/Gateway.csproj`
- `Gateway/global.json`
- `Gateway/nuget.config`
- `Gateway/Program.cs`
- `Gateway/Services/ChatManagerService.cs`
- `Gateway/Services/IChatManagerService.cs`
- `Gateway/Services/IWebSocketConnectionRegistry.cs`
- `Gateway/Services/RedisDeliverySubscriber.cs`
- `Gateway/Services/RedisUserPresenceStore.cs`
- `Gateway/Services/SupabaseChatHistoryStore.cs`
- `Gateway/Services/WebSocketConnectionRegistry.cs`
- `Gateway/Tests/ChatIntegrationTests.cs`
- `Gateway/Tests/Tests.csproj`

## Docker

- `Docker/.env.example`
- `Docker/.gitattributes`
- `Docker/BASELINE.md`
- `Docker/DEMO.md`
- `Docker/docker-compose.yaml`
- `Docker/rabbitmq-init.sh`
- `Docker/Start-Demo.ps1`
- `Docker/Stop-Demo.ps1`
- `Docker/TEST-RESULTS.md`

## Storage-Service

- `Storage-Service/appsettings.json`
- `Storage-Service/Database/Backfill/review_receiver_ids.sql`
- `Storage-Service/Database/Migrations/20260905_add_receiver_id.sql`
- `Storage-Service/Database/Migrations/20260906_require_receiver_id_for_new_messages.sql`
- `Storage-Service/Database/Migrations/20260911_get_or_create_private_room.sql`
- `Storage-Service/Database/README.md`
- `Storage-Service/Database/Tests/concurrent_private_room_test.sql`
- `Storage-Service/Database/Tests/receiver_id_migration_test.sql`
- `Storage-Service/Database/Tests/Run-MigrationTest.ps1`
- `Storage-Service/Dockerfile`
- `Storage-Service/Dockerfile.dockerignore`
- `Storage-Service/IChatMessageStore.cs`
- `Storage-Service/nuget.config`
- `Storage-Service/Program.cs`
- `Storage-Service/QueueReceiver.cs`
- `Storage-Service/README.md`
- `Storage-Service/Storage-Service.csproj`
- `Storage-Service/Storage-Service.Tests/EndToEnd/FrontendToDeliveryTests.cs`
- `Storage-Service/Storage-Service.Tests/EndToEnd/README.md`
- `Storage-Service/Storage-Service.Tests/EndToEnd/Support/E2eModels.cs`
- `Storage-Service/Storage-Service.Tests/EndToEnd/Support/E2eSettings.cs`
- `Storage-Service/Storage-Service.Tests/EndToEnd/Support/E2eSystem.cs`
- `Storage-Service/Storage-Service.Tests/EndToEnd/Support/EndToEndFactAttribute.cs`
- `Storage-Service/Storage-Service.Tests/README.md`
- `Storage-Service/Storage-Service.Tests/Run-E2E.ps1`
- `Storage-Service/Storage-Service.Tests/Storage-Service.Tests.csproj`
- `Storage-Service/Storage-Service.Tests/Unit/QueueReceiverTests.cs`
- `Storage-Service/Storage-Service.Tests/Unit/ReceiverMappingTests.cs`
- `Storage-Service/Storage-Service.Tests/Unit/SupabaseChatMessageStoreTests.cs`
- `Storage-Service/Storage-Service.Tests/Unit/WorkerPoolTests.cs`
- `Storage-Service/SupabaseChatMessageStore.cs`
- `Storage-Service/Worker.cs`
- `Storage-Service/WorkerPool.cs`

## Frontend

- `Frontend/.gitignore`
- `Frontend/chat-app/.dockerignore`
- `Frontend/chat-app/.gitignore`
- `Frontend/chat-app/Dockerfile`
- `Frontend/chat-app/package-lock.json`
- `Frontend/chat-app/package.json`
- `Frontend/chat-app/playwright.config.ts`
- `Frontend/chat-app/src/auth/auth-context.tsx`
- `Frontend/chat-app/src/chat/messages.ts`
- `Frontend/chat-app/src/chat/use-private-chat.ts`
- `Frontend/chat-app/src/components/chat-workspace.tsx`
- `Frontend/chat-app/src/e2ee/e2ee.ts`
- `Frontend/chat-app/src/styles.d.ts`
- `Frontend/chat-app/src/utils/api-client.ts`
- `Frontend/chat-app/src/utils/gateway.ts`
- `Frontend/chat-app/src/utils/supabase.ts`
- `Frontend/chat-app/tests/chat.test.ts`
- `Frontend/chat-app/tests/e2e/private-chat.spec.ts`

## UserService

- `UserService/.dockerignore`

## Main-Database

No changes.

This inventory itself is Docker/CHANGED-FILES.md.
