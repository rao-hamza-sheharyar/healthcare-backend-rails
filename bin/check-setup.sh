#!/bin/bash

echo "🔍 Healthcare System Setup Verification"
echo "========================================"
echo ""

# Check Ruby
echo "1. Checking Ruby..."
if command -v ruby &> /dev/null; then
    ruby_version=$(ruby --version | awk '{print $2}')
    echo "   ✓ Ruby found: $ruby_version"
    echo "   ⚠ Note: Rails 8.1 requires Ruby 3.1+, but will try to proceed"
else
    echo "   ✗ Ruby not found"
fi

# Check Node
echo ""
echo "2. Checking Node.js..."
if command -v node &> /dev/null; then
    node_version=$(node --version)
    echo "   ✓ Node.js found: $node_version"
else
    echo "   ✗ Node.js not found"
fi

# Check Rails
echo ""
echo "3. Checking Rails..."
if command -v rails &> /dev/null; then
    rails_version=$(rails --version 2>/dev/null | awk '{print $2}' || echo "unknown")
    echo "   ✓ Rails found: $rails_version"
else
    echo "   ✗ Rails not found"
fi

# Check database directory
echo ""
echo "4. Checking database setup..."
if [ -d "db/migrate" ]; then
    migration_count=$(find db/migrate -name "*.rb" 2>/dev/null | wc -l)
    echo "   ✓ Migrations directory exists ($migration_count migrations)"
else
    echo "   ✗ Migrations directory not found"
fi

# Check frontend directories
echo ""
echo "5. Checking frontend applications..."
for frontend in "../healthcare-frontend-client" "../healthcare-frontend-doctor" "../healthcare-frontend-admin"; do
    name=$(basename $frontend)
    if [ -d "$frontend" ]; then
        if [ -f "$frontend/package.json" ]; then
            echo "   ✓ $name: Found"
        else
            echo "   ⚠ $name: Directory exists but no package.json"
        fi
    else
        echo "   ✗ $name: Not found"
    fi
done

echo ""
echo "========================================"
echo "Setup Status Check Complete!"
echo ""
echo "To proceed with setup, run:"
echo "  cd healthcare-backend-rails"
echo "  ./bin/setup.sh"
echo ""


