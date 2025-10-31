Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Email testing interface (development only)
  # Only mount if letter_opener_web is available
  if Rails.env.development?
    begin
      require 'letter_opener_web'
      mount LetterOpenerWeb::Engine, at: "/letter_opener"
    rescue LoadError
      # letter_opener_web not available, skip mounting
    end
  end
  
  # Authentication
  post "auth/register", to: "auth#register"
  post "auth/login", to: "auth#login"
  get "auth/me", to: "auth#me"
  
  # Password Reset
  post "password_resets", to: "password_resets#create"
  patch "password_resets", to: "password_resets#update"
  put "password_resets", to: "password_resets#update"
  
  # Doctors
  get "doctors", to: "doctors#index"
  get "doctors/search", to: "doctors#search"
  get "doctors/:id", to: "doctors#show"
  patch "doctors/:id", to: "doctors#update"
  put "doctors/:id", to: "doctors#update"
  post "doctors/register", to: "doctors_registration#create"
  
  # Appointments
  get "appointments", to: "appointments#index"
  post "appointments", to: "appointments#create"
  get "appointments/:id", to: "appointments#show"
  patch "appointments/:id", to: "appointments#update"
  put "appointments/:id", to: "appointments#update"
  delete "appointments/:id", to: "appointments#destroy"
  post "appointments/:id/approve", to: "appointments#approve"
  post "appointments/:id/reject", to: "appointments#reject"
  post "appointments/:id/cancel", to: "appointments#cancel"
  post "appointments/:id/reschedule", to: "appointments#reschedule"
  post "appointments/:id/request_reschedule", to: "appointments#request_reschedule"
  post "appointments/:id/approve_reschedule_request", to: "appointments#approve_reschedule_request"
  post "appointments/:id/reject_reschedule_request", to: "appointments#reject_reschedule_request"
  
  # Reviews
  get "reviews", to: "reviews#index"
  post "reviews", to: "reviews#create"
  get "reviews/:id", to: "reviews#show"
  patch "reviews/:id", to: "reviews#update"
  put "reviews/:id", to: "reviews#update"
  delete "reviews/:id", to: "reviews#destroy"
  
  # Users (for profile management)
  get "users/me", to: "users#me"
  patch "users/me", to: "users#update_me"
  
  # Admin routes
  namespace :admin do
    get "analytics", to: "admin#analytics"
    get "users", to: "users#index"
    post "users", to: "users#create"
    get "users/:id", to: "users#show"
    patch "users/:id", to: "users#update"
    put "users/:id", to: "users#update"
    delete "users/:id", to: "users#destroy"
    get "doctors", to: "doctors#index"
    post "doctors", to: "doctors_registration#create"
    patch "doctors/:id", to: "doctors#update"
    put "doctors/:id", to: "doctors#update"
    delete "doctors/:id", to: "doctors#destroy"
    post "appointments/book", to: "admin#book_appointment_for_client"
  end
end
