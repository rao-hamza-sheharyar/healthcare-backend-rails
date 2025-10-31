#!/bin/bash
set -e

echo "🏥 Healthcare Backend Setup Script"
echo "===================================="

# Check Ruby version
echo "Checking Ruby version..."
ruby_version=$(ruby --version 2>&1 | head -1)
echo "Found: $ruby_version"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
bundle install

# Setup database
echo ""
echo "💾 Setting up database..."
rails db:create || echo "Database might already exist"
rails db:migrate
rails db:seed

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the server, run:"
echo "  rails server"
echo ""
echo "Default login credentials:"
echo "  Admin: admin@healthcare.com / admin123"
echo "  Doctor: doctor@healthcare.com / doctor123"
echo "  Client: client@healthcare.com / client123"


