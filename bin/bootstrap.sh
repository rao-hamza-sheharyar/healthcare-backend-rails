#!/usr/bin/env bash
set -euo pipefail
if [ ! -f ".rails_created" ]; then
  docker compose run --no-deps --rm web bash -lc "gem install rails -v \"~>7.1\" && rails new . --api -T -d postgresql --force"
  touch .rails_created
fi
# Ensure gems are installed and containers up
docker compose build
docker compose up -d
