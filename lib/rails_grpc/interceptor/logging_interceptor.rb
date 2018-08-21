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
        logger.debug("[GRPC] #{grpc_method}")
        t = Time.now

        yield

        t = Time.now - t
        display_duration = "%.1f ms" % (t * 1000.0)
        logger.debug("[GRPC response] (#{display_duration}) #{grpc_method}")
      end
    end
  end
end
