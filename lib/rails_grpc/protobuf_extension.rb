require 'google/protobuf'

module Google
  module Protobuf
    module Internal
      class Builder
        alias_method :original_add_message, :add_message

        def add_message(v)
          RailsGrpc::Loader.send(:add_loaded_class, v)

          original_add_message v
        end
      end
    end
  end
end
