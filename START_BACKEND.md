# Starting the Backend Server

## Current Situation

Your system has **Ruby 2.7.0** but **Rails 8.1 requires Ruby 3.1+**.

## Quick Solutions

### Option 1: Use Docker (Easiest)

```bash
cd healthcare-backend-rails
docker-compose up
```

This will:
- Start PostgreSQL database
- Install dependencies
- Run migrations
- Seed database  
- Start Rails server on port 3000

### Option 2: Install Ruby 3.2.4 with rbenv

```bash
# Install rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Add to your shell profile
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install and use Ruby 3.2.4
rbenv install 3.2.4
cd healthcare-backend-rails
rbenv local 3.2.4

# Now setup
bundle install
rails db:create db:migrate db:seed
rails server
```

### Option 3: Temporary Fix - Use Compatible SQLite Version

I've updated the Gemfile to use sqlite3 ~> 1.6 which might work with Ruby 2.7, but Rails 8.1 still requires Ruby 3.1+. This is not recommended but might work for testing.

## Frontends Status

The frontend applications should be starting on:
- Client: http://localhost:5173
- Doctor: http://localhost:5174
- Admin: http://localhost:5175

They will show errors until the backend API (port 3000) is running.

## Recommended Action

**Use Docker** - it's the fastest way to get everything running:
```bash
docker-compose up
```


