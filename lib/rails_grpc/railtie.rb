require "rails"
require "rails_grpc/dependencies"
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
      unless RailsGrpc::Dependencies.cache_classes?
        Google::Protobuf::DescriptorPool.generated_pool.clear
        RailsGrpc::Dependencies.clear_dependencies!
        RailsGrpc::Dependencies.load_dependencies!
      end
    end
  end
end
