require "grpc"

module GRPC
  class RpcServer
    attr_accessor :application_reload

    # handles calls to the server
    def loop_handle_server_calls
      fail 'not started' if running_state == :not_started
      while running_state == :running
        begin
          an_rpc = @server.request_call
          break if (!an_rpc.nil?) && an_rpc.call.nil?
          active_call = new_active_server_call(an_rpc)
          unless active_call.nil?
            @pool.schedule(active_call) do |ac|
              c, mth = ac
              begin
                # extended for reloader
                @application_reload.call unless @application_reload.nil?
                # extended for reloader

                rpc_descs[mth].run_server_method(
                  c,
                  rpc_handlers[mth],
                  @interceptors.build_context
                )
              rescue StandardError
                c.send_status(GRPC::Core::StatusCodes::INTERNAL,
                              'Server handler failed')
              end
            end
          end
        rescue Core::CallError, RuntimeError => e
          # these might happen for various reasons.  The correct behavior of
          # the server is to log them and continue, if it's not shutting down.
          if running_state == :running
            GRPC.logger.warn("server call failed: #{e}")
          end
          next
        end
      end
      # @running_state should be :stopping here
      @run_mutex.synchronize do
        transition_running_state(:stopped)
        GRPC.logger.info("stopped: #{self}")
        @server.close
      end
    end

    def add_force_rpc_descs_for(service)
      cls = service.is_a?(Class) ? service : service.class
      specs, handlers = (@rpc_descs ||= {}), (@rpc_handlers ||= {})
      cls.rpc_descs.each_pair do |name, spec|
        route = "/#{cls.service_name}/#{name}".to_sym
        # fail "already registered: rpc #{route} from #{spec}" if specs.key? route
        specs[route] = spec
        rpc_name = GenericService.underscore(name.to_s).to_sym
        if service.is_a?(Class)
          handlers[route] = cls.new.method(rpc_name)
        else
          handlers[route] = service.method(rpc_name)
        end
        GRPC.logger.info("handling #{route} with #{handlers[route]}")
      end
    end
  end
end
