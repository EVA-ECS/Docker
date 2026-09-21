#!/bin/sh
set -eu
# Import AFTER first boot: boot-time definitions suppress RabbitMQ's default user.
# This one-shot infrastructure job has no public port and stores no credentials.
rabbitmqctl --node rabbit@rabbitmq await_startup --timeout 60
rabbitmqctl --node rabbit@rabbitmq import_definitions /etc/rabbitmq/definitions.json
rabbitmqctl --node rabbit@rabbitmq authenticate_user "$RABBITMQ_DEFAULT_USER" "$RABBITMQ_DEFAULT_PASS" >/dev/null
