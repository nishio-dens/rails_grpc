require 'grpc'

module GRPC
  module GenericService
    module Dsl
      alias_method :original_rpc, :rpc

      def rpc(name, input, output)
        RailsGrpc::Loader.send(:add_loaded_service, self)

        original_rpc(name, input, output)
      end
    end
  end
end
