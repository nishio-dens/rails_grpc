require "grpc"
require "rails"
require "rails_grpc/interceptor/logging_interceptor"

# TODO: Autoreload
module RailsGrpc
  class GeneralServer
    attr_accessor :port, :pool_size

    def initialize(port:, pool_size: nil)
      @interceptors = [
        RailsGrpc::Interceptor::LoggingInterceptor.new
      ]

      @grpc_server = if pool_size.present?
                       GRPC::RpcServer.new(pool_size: pool_size, interceptors: @interceptors)
                     else
                       GRPC::RpcServer.new(interceptors: @interceptors)
                     end
      @grpc_server.add_http2_port(port, :this_port_is_insecure)
    end

    def set_handlers(handlers)
      hs = Array(handlers)
      hs.each do |h|
        @grpc_server.handle(h)
      end
    end

    def run
      @grpc_server.run_till_terminated
    end
  end
end
