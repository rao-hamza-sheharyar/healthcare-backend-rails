#!/usr/bin/env bash
set -e
cd /app
if [ ! -f "bin/rails" ]; then
  echo "Rails app not found. Generating new API app..."
  rails new . --api -T -d postgresql --skip-jbuilder --skip-sprockets --skip-action-mailbox --skip-action-text --skip-active-storage
  # Configure database to use env DATABASE_URL
  sed -i "s#^  url:.*#  url: <%= ENV[DATABASE_URL] %>#" config/database.yml || true
  bundle install
  bin/rails db:prepare
fi
exec ""
