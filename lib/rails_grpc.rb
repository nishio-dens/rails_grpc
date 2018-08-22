require "rails_grpc/version"

module RailsGrpc
end

if defined?(Rails)
  require "rails_grpc/dependencies"
  require "rails_grpc/reloader"

  require "rails_grpc/extension/rpc_server"

  require "rails_grpc/logger"
  require "rails_grpc/interceptor/logging_interceptor"
  require "rails_grpc/general_server"

  require "rails_grpc/railtie"
end
