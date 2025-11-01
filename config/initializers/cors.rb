Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow specific origins for production
    origins_list = [
      # Local development
      "http://localhost:5173",  # Client frontend
      "http://localhost:5174",  # Doctor frontend
      "http://localhost:5175",  # Admin frontend
      # Production (update with actual Vercel URLs after deployment)
      ENV['FRONTEND_CLIENT_URL'],
      ENV['FRONTEND_DOCTOR_URL'],
      ENV['FRONTEND_ADMIN_URL']
    ].compact.reject(&:blank?)
    
    origins(*origins_list)
    
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end
