require "rails_grpc/version"

module RailsGrpc
  # required
  require "rails_grpc/dependencies"
  require "rails_grpc/railtie"
  require "rails_grpc/logger"
  require "rails_grpc/interceptor/logging_interceptor"

  # extension
  require "rails_grpc/extension/rpc_server"

  # options
  autoload :Reloader, "rails_grpc/reloader"
  autoload :GeneralServer, "rails_grpc/general_server"
end
