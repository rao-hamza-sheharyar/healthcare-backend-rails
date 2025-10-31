#!/bin/bash

echo "🚀 Starting Healthcare Backend API"
echo "===================================="

# Check if PostgreSQL is running
if pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "✓ PostgreSQL is running on port 5432"
    export DATABASE_URL="postgres://postgres:postgres@localhost:5432/postgres"
else
    echo "⚠ PostgreSQL not found, trying Docker..."
    docker-compose up -d db
    sleep 5
    export DATABASE_URL="postgres://postgres:postgres@localhost:5433/postgres"
fi

echo ""
echo "📦 Setting up database..."
echo "DATABASE_URL=$DATABASE_URL"

# Note: This requires Ruby 3.1+
echo ""
echo "⚠️  NOTE: Rails 8.1 requires Ruby 3.1+"
echo "Current Ruby version: $(ruby --version 2>&1 | head -1)"
echo ""
echo "If you see errors, you need to:"
echo "1. Install Ruby 3.2.4 (see RUBY_VERSION_NOTICE.md)"
echo "2. OR use Docker: docker-compose up"
echo ""
echo "Attempting to start server..."
echo ""

# Try to start (will fail if Ruby version is wrong)
rails db:create 2>&1 || echo "Database creation failed - need Ruby 3.1+"
rails db:migrate 2>&1 || echo "Migration failed - need Ruby 3.1+"
rails db:seed 2>&1 || echo "Seeding failed - need Ruby 3.1+"
rails server 2>&1 || echo "Server failed to start - need Ruby 3.1+"


