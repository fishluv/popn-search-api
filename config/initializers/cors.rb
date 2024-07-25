# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:3001", # Local
            "dev.popn.tools", # Test
            "popn.tools"      # Prod
    resource "*", headers: :any, methods: :get, credentials: true
  end
end
