require "grpc"
require "rails_grpc/interceptor/logging_interceptor"
require "rails_grpc/dependencies"

module RailsGrpc
  class GeneralServer
    attr_accessor :port, :pool_size, :logger, :grpc_server, :handlers, :interceptors

    def initialize(port:, pool_size: nil, logger: Rails.logger)
      self.port = port
      self.pool_size = pool_size
      self.logger = logger
      self.handlers = []

      self.interceptors = [
        RailsGrpc::Interceptor::LoggingInterceptor.new(RailsGrpc::Logger.logger(logger))
      ]

      self.grpc_server = if pool_size.present?
                           GRPC::RpcServer.new(pool_size: pool_size, interceptors: self.interceptors)
                         else
                           GRPC::RpcServer.new(interceptors: self.interceptors)
                         end
      self.grpc_server.add_http2_port(port, :this_port_is_insecure)
      set_reloader
    end

    def set_reloader
      unless RailsGrpc::Dependencies.cache_classes?
        @grpc_server.application_reload = lambda do
          changed = Rails.application.reloader.check.call
          if changed
            @logger.info("Reloading GRPC Server...")
            Rails.application.reloader.reload!
            @logger.info("Reset GRPC services...")

            @handlers.each do |h|
              reloaded_handler = h.to_s.constantize
              @grpc_server.send(:add_force_rpc_descs_for, reloaded_handler)
            end
          end
        end
      end
    end

    def set_handlers(handlers)
      hs = Array(handlers)
      hs.each do |h|
        @grpc_server.handle(h)
      end
      @handlers.concat(hs)
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
