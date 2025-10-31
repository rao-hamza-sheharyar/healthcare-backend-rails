# Healthcare System Setup Guide

## Quick Start

### Backend Setup

```bash
cd healthcare-backend-rails

# Install dependencies (requires Ruby 3.2.4)
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start server
rails server
# API will be at http://localhost:3000
```

### Frontend Setup

#### Client Frontend
```bash
cd healthcare-frontend-client
npm install
npm run dev
# Will run on http://localhost:5173 (or similar)
```

#### Doctor Frontend
```bash
cd healthcare-frontend-doctor
npm install
npm run dev
# Will run on http://localhost:5174 (or similar)
```

#### Admin Frontend
```bash
cd healthcare-frontend-admin
npm install
npm run dev
# Will run on http://localhost:5175 (or similar)
```

## Default Login Credentials (from seeds)

- **Admin**: admin@healthcare.com / admin123
- **Doctor**: doctor@healthcare.com / doctor123
- **Client**: client@healthcare.com / client123

## Features Implemented

### Client Portal
✅ Homepage with navbar, top doctors, reviews, footer
✅ Search doctors by name/specialization
✅ Book appointments
✅ View and update profile
✅ Login/Register

### Doctor Portal
✅ Dashboard with statistics
✅ View new bookings
✅ Approve/Reject appointments with reasons
✅ View previously dealt patients
✅ Register as doctor
✅ Update doctor profile

### Admin Portal
✅ Dashboard with analytics
✅ View all doctors and clients
✅ Add new clients
✅ Edit/Delete doctors and clients
✅ Book appointments on behalf of clients

## API Configuration

Update the API URL in each frontend's environment or `.env` file:
- Create `.env` file in each frontend directory
- Add: `VITE_API_URL=http://localhost:3000`

## Next Steps

1. **Email Setup**: Configure ActionMailer to send login credentials
2. **Production**: Update CORS origins in `config/initializers/cors.rb`
3. **Security**: Change JWT secret key in production
4. **Database**: Switch to PostgreSQL for production

