# Verteiltes Chat-System

Compose startet die öffentlichen Komponenten (Traefik und Gateway) sowie die
internen Infrastruktur- und Worker-Komponenten:

- `rabbitmq` und `redis` bleiben im internen `data-net`;
- `storage-worker` konsumiert `storage_queue` und schreibt nach Supabase;
- `delivery-worker` konsumiert `delivery_queue` und veröffentlicht online
  Nachrichten über Redis Pub/Sub.

Die Worker haben keine öffentlichen HTTP-Ports und werden über
`STORAGE_WORKER_COUNT`, `DELIVERY_WORKER_COUNT`, RabbitMQ-/Redis-Variablen und
`SUPABASE_CONNECTION_STRING` konfiguriert. Zugangsdaten gehören nur in eine
lokale `.env` beziehungsweise in die Laufzeitumgebung.
