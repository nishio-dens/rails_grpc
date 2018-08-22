require "rails_grpc/dependencies"

module RailsGrpc
  module Reloader
    class << self
      def reload!
        unless RailsGrpc::Dependencies.cache_classes?
          Google::Protobuf::DescriptorPool.generated_pool.clear
          RailsGrpc::Dependencies.clear_dependencies!
          RailsGrpc::Dependencies.load_dependencies!
        end
      end
    end
  end
end
