require "rails_grpc/version"

module RailsGrpc
end

if defined?(Rails)
  require "rails_grpc/protobuf_extension"
  require "rails_grpc/grpc_extension"
  require "rails_grpc/loader"
  require "rails_grpc/rails"
end
