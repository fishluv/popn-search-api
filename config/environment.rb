# Load the Rails application.
require_relative "application"

# Set up logger early to capture initializer logs.
Rails.logger = Logger.new(STDOUT)

# Initialize the Rails application.
Rails.application.initialize!
