# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Local frontends
    origins "localhost:3001"
    resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete], credentials: true
  end

  allow do
    # Production frontends
    origins "popn.tools"
    resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete], credentials: true
  end
end
