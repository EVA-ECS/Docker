# Verteiltes Chat-System

`docker-compose.yaml` bleibt die normale Team-Konfiguration aus `dev`.
Die ergänzende private Chat-Demo wird ausdrücklich über `Start-Demo.ps1`
und `docker-compose.integration.yaml` gestartet. So werden die bestehenden
Container, Ports und Datenvolumes nicht ersetzt.

**Vor dem Start:** [PUBLICATION.md](PUBLICATION.md) nennt die passenden PRs und
die noch unveröffentlichten Storage-Build-Anpassungen, die Zein prüfen muss.
Ein unverändertes GitHub-main-Checkout reicht für die neue Demo noch nicht.

[DEMO.md](DEMO.md) enthält Einrichtung, zwei Benutzer, Verlauf nach Refresh,
Offline-Test und sicheres Stoppen. Zugangsdaten stehen nur in einer privaten
`.env`; `.env.example` enthält ausschließlich Platzhalter. Verwendet werden
Supabase-URL und API-Schlüssel, kein direkter Datenbank-Connection-String.

Die Demo-Worker haben keine öffentlichen HTTP-Ports. Storage speichert zuerst,
Delivery leitet danach weiter. Redis-Pub/Sub ist keine dauerhafte Speicherung.
