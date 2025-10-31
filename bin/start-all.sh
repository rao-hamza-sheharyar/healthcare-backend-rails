#!/bin/bash

echo "🏥 Starting Healthcare System"
echo "=============================="
echo ""
echo "Starting backend server on port 3000..."
echo "Starting client frontend on port 5173..."
echo "Starting doctor frontend on port 5174..."
echo "Starting admin frontend on port 5175..."
echo ""

# Start backend
cd /home/arslan/healthcare-backend-rails
rails server &
BACKEND_PID=$!
echo "Backend started (PID: $BACKEND_PID)"
sleep 3

# Start client frontend
cd /home/arslan/healthcare-frontend-client
npm run dev &
CLIENT_PID=$!
echo "Client frontend started (PID: $CLIENT_PID)"
sleep 2

# Start doctor frontend
cd /home/arslan/healthcare-frontend-doctor
npm run dev &
DOCTOR_PID=$!
echo "Doctor frontend started (PID: $DOCTOR_PID)"
sleep 2

# Start admin frontend
cd /home/arslan/healthcare-frontend-admin
npm run dev &
ADMIN_PID=$!
echo "Admin frontend started (PID: $ADMIN_PID)"
sleep 2

echo ""
echo "✅ All services started!"
echo ""
echo "Access the applications:"
echo "  Client: http://localhost:5173"
echo "  Doctor: http://localhost:5174"
echo "  Admin:  http://localhost:5175"
echo "  API:    http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Wait for interrupt
trap "kill $BACKEND_PID $CLIENT_PID $DOCTOR_PID $ADMIN_PID 2>/dev/null; exit" INT TERM
wait


