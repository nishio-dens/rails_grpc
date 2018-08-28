require "grpc"

module RailsGrpc
  module Interceptor
    class LoggingInterceptor < ::GRPC::ServerInterceptor
      def initialize(logger)
        @logger = logger
      end

      def request_response(request: nil, call: nil, method: nil)
        grpc_method = "#{method.owner.name}##{method.name}"
        logger = @logger
        logger.info("[GRPC] #{grpc_method}")
        t = Time.now

        begin
          yield
        rescue => e
          logger.error(e)
          logger.error(e.backtrace.join("\n"))
          raise e
        end

        t = Time.now - t
        display_duration = "%.1f ms" % (t * 1000.0)
        logger.info("[GRPC response] (#{display_duration}) #{grpc_method}")
      end
    end
  end
end
