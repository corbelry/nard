#!/bin/sh
# Production API entrypoint (ADR-047). On a read-only root, /app/storage and
# /tmp are empty volumes: recreate the directories Laravel expects (compiled
# views must exist before the first render), then run the command.
set -e
mkdir -p \
    /app/storage/framework/cache/data \
    /app/storage/framework/sessions \
    /app/storage/framework/views \
    /app/storage/logs \
    /app/storage/app/private \
    /app/storage/app/public
exec "$@"
