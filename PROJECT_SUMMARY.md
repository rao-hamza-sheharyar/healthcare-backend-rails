# Healthcare Management System - Project Summary

## Overview
A complete healthcare management system with separate portals for Clients, Doctors, and Administrators, built with Rails 8.1 API backend and three React TypeScript frontends.

## Architecture

### Backend (Rails 8.1 API)
- **Technology**: Ruby on Rails 8.1.1, JWT Authentication, PostgreSQL/SQLite
- **Key Features**:
  - RESTful API with role-based authentication
  - JWT token-based authentication
  - Automatic doctor rating calculation from reviews
  - Comprehensive admin analytics

### Frontend Applications
1. **Client Frontend** (React + TypeScript + Vite)
   - Patient/Client portal
   - Search and book appointments
   - View doctor profiles and reviews

2. **Doctor Frontend** (React + TypeScript + Vite)
   - Doctor dashboard
   - Appointment management
   - Patient history

3. **Admin Frontend** (React + TypeScript + Vite)
   - System administration
   - User/Doctor management
   - Analytics dashboard

## Database Schema

### Users
- Email, password (bcrypt), name, phone, address, role (client/admin/doctor)

### Doctors
- User reference, specialization, description, qualifications, experience, rating, reviews count, license

### Appointments
- User, Doctor, date, status (pending/approved/rejected), rejection_reason, notes

### Reviews
- User, Doctor, Appointment (optional), rating (1-5), comment

## API Endpoints Summary

### Public Endpoints
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /doctors` - List doctors (public)
- `GET /doctors/search` - Search doctors (public)
- `GET /doctors/:id` - Doctor details (public)
- `GET /reviews?doctor_id=X` - Doctor reviews (public)

### Authenticated Endpoints
- `GET /auth/me` - Current user
- `GET /users/me` - Current user profile
- `PATCH /users/me` - Update profile
- `POST /appointments` - Book appointment
- `GET /appointments` - List appointments
- `POST /appointments/:id/approve` - Approve (doctor)
- `POST /appointments/:id/reject` - Reject (doctor)
- `POST /doctors/register` - Register as doctor
- `PATCH /doctors/:id` - Update doctor profile

### Admin Only Endpoints
- `GET /admin/analytics` - System statistics
- `GET /admin/users` - List users
- `POST /admin/users` - Create user
- `PATCH/DELETE /admin/users/:id` - Manage users
- `GET /admin/doctors` - List all doctors
- `POST /admin/doctors` - Create doctor
- `PATCH/DELETE /admin/doctors/:id` - Manage doctors
- `POST /admin/appointments/book` - Book for client

## User Flows

### Client Flow
1. Register/Login
2. Browse/search doctors on homepage
3. View doctor profiles with ratings and reviews
4. Book appointment
5. View appointment status
6. Write reviews after appointments

### Doctor Flow
1. Register as regular user, then register as doctor
2. Login to doctor portal
3. View new bookings (pending appointments)
4. Approve or reject with reasons
5. View previously dealt patients
6. Update profile

### Admin Flow
1. Login as admin
2. View analytics dashboard
3. Manage doctors (view, edit, delete)
4. Manage clients (add, edit, delete, email credentials)
5. Book appointments on behalf of clients

## Security Features
- JWT token authentication (24-hour expiration)
- Password hashing with bcrypt
- Role-based access control
- CORS configuration for frontend origins
- Protected routes with authentication middleware

## Next Steps for Production
1. Configure email service (ActionMailer) for sending credentials
2. Update CORS to specific frontend domains
3. Set up proper secret key management
4. Switch to PostgreSQL in production
5. Add rate limiting
6. Implement file uploads for doctor photos/licenses
7. Add pagination for large lists
8. Add filtering and sorting options
9. Implement real-time notifications (ActionCable)
10. Add comprehensive error logging

## Testing
To test the system:
1. Run seeds to create sample users
2. Start backend: `rails server`
3. Start each frontend in separate terminals
4. Test each role's functionality

## Notes
- SQLite used for development (change LIKE to ILIKE for PostgreSQL)
- Email sending is stubbed (returns password in response)
- All three frontends are independent and communicate via API
- Doctor ratings automatically update when reviews are added/removed


