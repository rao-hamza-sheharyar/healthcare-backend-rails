# Healthcare Backend Rails API

A comprehensive healthcare management system with separate frontends for clients, doctors, and administrators.

## Features

- **User Management**: Clients, Doctors, and Admins with role-based authentication
- **Doctor Profiles**: Specialization, ratings, reviews, and experience tracking
- **Appointment System**: Book, approve, and reject appointments with reasons
- **Review System**: Client reviews with ratings that update doctor ratings
- **Admin Dashboard**: Analytics, user/doctor management, and appointment booking

## Setup

### Prerequisites
- Ruby 3.2.4
- PostgreSQL (for production) or SQLite (for development)
- Rails 8.1.1

### Installation

1. Install dependencies:
```bash
bundle install
```

2. Setup database:
```bash
rails db:create
rails db:migrate
rails db:seed  # Creates sample admin, doctor, and client users
```

3. Start the server:
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `GET /auth/me` - Get current user

### Doctors
- `GET /doctors` - List all doctors (sorted by rating)
- `GET /doctors/search?query=...&specialization=...` - Search doctors
- `GET /doctors/:id` - Get doctor details
- `PATCH /doctors/:id` - Update doctor profile (owner or admin only)
- `POST /doctors/register` - Register as doctor (authenticated user)

### Appointments
- `GET /appointments` - List appointments (filtered by user role)
- `POST /appointments` - Create appointment
- `GET /appointments/:id` - Get appointment details
- `PATCH /appointments/:id` - Update appointment
- `POST /appointments/:id/approve` - Approve appointment (doctor only)
- `POST /appointments/:id/reject` - Reject appointment with reason (doctor only)
- `DELETE /appointments/:id` - Cancel appointment

### Reviews
- `GET /reviews?doctor_id=...` - Get reviews for a doctor
- `POST /reviews` - Create review
- `PATCH /reviews/:id` - Update review
- `DELETE /reviews/:id` - Delete review

### Users
- `GET /users/me` - Get current user profile
- `PATCH /users/me` - Update current user profile

### Admin Endpoints
- `GET /admin/analytics` - Get system analytics
- `GET /admin/users?role=...` - List users
- `POST /admin/users` - Create user (admin only)
- `PATCH /admin/users/:id` - Update user
- `DELETE /admin/users/:id` - Delete user
- `GET /admin/doctors` - List all doctors
- `POST /admin/doctors` - Create doctor (admin only)
- `PATCH /admin/doctors/:id` - Update doctor
- `DELETE /admin/doctors/:id` - Delete doctor
- `POST /admin/appointments/book` - Book appointment on behalf of client

## Authentication

All authenticated endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## Sample Users (from seeds)

- **Admin**: admin@healthcare.com / admin123
- **Doctor**: doctor@healthcare.com / doctor123
- **Client**: client@healthcare.com / client123

## Frontend Applications

This backend serves three separate frontend applications:
1. **Client Frontend** - Patient portal for searching doctors and booking appointments
2. **Doctor Frontend** - Doctor dashboard for managing appointments
3. **Admin Frontend** - Admin panel for system management

## Development Notes

- JWT tokens expire after 24 hours
- Doctor ratings are automatically updated when reviews are added/removed
- Email functionality for sending credentials is stubbed (TODO: implement ActionMailer)
