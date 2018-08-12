require "grpc"

# FIXME
#   - rails logger
module RailsGrpc
  module Interceptor
    class LoggingInterceptor < ::GRPC::ServerInterceptor
      def request_response(request:, call:, method:)
        p "Received request/response call at method #{method}" \
          " with request #{request} for call #{call}"
        call.output_metadata[:interc] = 'from_request_response'
        p "[GRPC::Ok] (#{method.owner.name}.#{method.name})"

        yield
      end
    end
  end
end
