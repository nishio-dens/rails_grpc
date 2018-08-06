require 'rails'
require 'google/protobuf'
require 'grpc'

module RailsGrpc
  module Loader
    @@grpc_proto_lib_dir = "/proto/lib"
    @@loaded = false
    @@loaded_classes = []
    @@loaded_services = []

    ActiveSupport.on_load(:before_initialize) do
      ::Rails.application.config.to_prepare do
        RailsGrpc::Loader.prepare
      end
    end

    def self.prepare
      $LOAD_PATH.unshift(grpc_libs)

      if @@loaded
        Google::Protobuf::DescriptorPool.generated_pool.clear
        clear_grpc_classes
      end

      load_definitions
      load_services

      @@loaded = true
    end

    def self.grpc_libs
      "#{::Rails.root}#{@@grpc_proto_lib_dir}"
    end

    def self.proto_files
      Dir.glob("#{grpc_libs}/**/*.rb")
    end

    def self.load_services
      proto_files.select { |t| t.include?("_services_pb.rb") }.each do |file|
        load file
      end
    end

    def self.load_definitions
      proto_files.reject { |t| t.include?("_services_pb.rb") }.each do |file|
        load file
      end
    end

    def self.clear_grpc_classes
      @@loaded_classes.uniq.each { |klass| clear_class(klass) }
      @@loaded_services.uniq.each do |klass|
        stub_class = "#{klass.constantize.parent}::Stub"
        if defined?(stub_class)
          clear_class(stub_class)
        end
        clear_class(klass)
      end

      RailsGrpc::Loader.clear_loaded_classes
      RailsGrpc::Loader.clear_loaded_services
    end

    def self.clear_class(klass)
      if defined?(klass)
        klass.constantize.parent.class_eval do
          k = klass.split("::")[-1]
          remove_const(k.to_sym)
        end
      end
    end

    def self.add_loaded_class(klass)
      @@loaded_classes << klass.split(".").map(&:camelize).join("::")
    end

    def self.clear_loaded_classes
      @@loaded_classes = []
    end

    def self.add_loaded_service(klass)
      @@loaded_services << klass.to_s
    end

    def self.clear_loaded_services
      @@loaded_services = []
    end
  end
end

