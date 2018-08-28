module RailsGrpc
  class Boot
    attr_accessor :server

    GRPC_DEFAULT_PORT = "127.0.0.1:5050"
    GRPC_DEFAULT_POOL_SIZE = 1
    RAILS_BOOT_PATH  = "config/environment.rb"
    GRPC_CONFIG_PATH = "config/grpc.yml"

    def exec(environment)
      require File.expand_path(RAILS_BOOT_PATH) # Load rails
      require "rails_grpc/general_server"

      c = config[environment]
      @server = RailsGrpc::GeneralServer.new(
        port: c["server"]["port"] || GRPC_DEFAULT_PORT,
        pool_size: c["server"]["pool_size"] || GRPC_DEFAULT_POOL_SIZE
      )
      @server.set_handlers(c["handlers"].map(&:constantize))
      @server.run
    end

    private

    def config
      @_config ||= load_config_file
    end

    def load_config_file
      if File.exist?(GRPC_CONFIG_PATH)
        require 'erb'
        YAML.load(ERB.new(IO.read(GRPC_CONFIG_PATH)).result)
      else
        puts "config/grpc.yml file not found."
        exit 1
      end
    end
  end
end
