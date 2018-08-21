require "grpc"
require "rails"
require "rails_grpc/interceptor/logging_interceptor"

# TODO: Autoreload
module RailsGrpc
  class GeneralServer
    attr_accessor :port, :pool_size, :logger

    def initialize(port:, pool_size: nil, logger: Rails.logger)
      self.port = port
      self.pool_size = pool_size
      self.logger = logger

      @interceptors = [
        RailsGrpc::Interceptor::LoggingInterceptor.new(RailsGrpc::Logger.logger(logger))
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
      @logger.info("GRPC server running on #{port}")
      begin
        @grpc_server.run_till_terminated
      rescue SystemExit, Interrupt
        # server does not stop gracefully because of it is a bug of grpc ruby.
        # see: https://github.com/grpc/grpc/issues/14043
        @logger.info("GRPC server goodbye!")
        @grpc_server.stop
      end
    end
  end
end
