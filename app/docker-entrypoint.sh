#!/bin/sh
set -e

echo "Running database migrations..."
bundle exec rails db:migrate

echo "Starting Passenger on port ${PORT:-3000}..."
exec bundle exec passenger start -e production --port "${PORT:-3000}" --address 0.0.0.0
