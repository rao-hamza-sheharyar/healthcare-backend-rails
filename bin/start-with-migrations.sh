#!/bin/bash
set -e

echo "🔧 Running database migrations..."
bundle exec rails db:migrate || echo "⚠️  Migration failed, but continuing..."

echo "🚀 Starting Puma server..."
exec bundle exec puma -C config/puma.rb

