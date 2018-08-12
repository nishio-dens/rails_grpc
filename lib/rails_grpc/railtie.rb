require "rails"
require "rails_grpc/dependencies"
require "rails_grpc/reloader"
require "google/protobuf"

module RailsGrpc
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/protoc.rake"
    end

    config.before_initialize do |app|
      RailsGrpc::Dependencies.load_dependencies!
    end

    ActiveSupport::Reloader.to_complete do
      RailsGrpc::Reloader.reload!
    end
  end
end
