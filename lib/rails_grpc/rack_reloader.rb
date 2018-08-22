require "rails_grpc/dependencies"

module RailsGrpc
  class RackReloader
    def initialize(app)
      @app = app
    end

    def call(env)
      unless RailsGrpc::Dependencies.cache_classes?
        changed = Rails.application.reloader.check.call
        if changed
          Rails.application.reloader.reload!
        end
      end
      @app.call(env)
    end
  end
end
