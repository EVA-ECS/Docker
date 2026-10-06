```bash

docker compose up --scale rabbitmq=1 --scale chat-gateway=2 --scale storage-worker=2 --scale delivery-worker=2 --scale user-service=2 -d 
```