require "rails_grpc/version"

module RailsGrpc
end

if defined?(Rails)
  require "rails_grpc/dependencies"
  require "rails_grpc/reloader"
  require "rails_grpc/railtie"
end
