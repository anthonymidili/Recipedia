#!/bin/sh
set -e

# Detect architecture and set jemalloc preload
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
elif [ "$ARCH" = "arm64" ]; then
    export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so.2
fi

echo "Running database migrations..."
bundle exec rails db:migrate

echo "Starting Passenger on port ${PORT:-3000}..."
exec bundle exec passenger start -e production --port "${PORT:-3000}" --address 0.0.0.0
