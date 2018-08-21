require "rails"

module RailsGrpc
  module Dependencies
    mattr_accessor :proto_lib_dir
    mattr_accessor :grpc_model_dir
    mattr_accessor :grpc_service_dir

    @@proto_lib_dir      = "grpc/lib"
    @@grpc_model_dir     = "grpc/models"
    @@grpc_service_dir   = "grpc/services"
    @@loaded             = false

    class << self
      def rails_root
        ::Rails.root
      end

      def find_proto_lib_files
        Dir.glob(File.join(rails_root, proto_lib_dir, "**/*.rb"))
      end

      def find_proto_message_definitions
        find_proto_lib_files.reject do |t|
          File.basename(t).include?("_services_pb.rb")
        end
      end

      def find_proto_service_definitions
        find_proto_lib_files.select do |t|
          File.basename(t).include?("_services_pb.rb")
        end
      end

      def find_grpc_model_files
        Dir.glob(File.join(rails_root, grpc_model_dir, "**/*.rb"))
      end

      def find_grpc_service_files
        Dir.glob(File.join(rails_root, grpc_service_dir, "**/*.rb"))
      end

      def cache_classes?
        ::Rails.application.config.cache_classes
      end

      def load_dependencies!
        return if @@loaded

        find_proto_message_definitions.each do |f|
          parent_const_name = File.basename(f).gsub(".", "::").split("::")[0].classify
          load_and_watch(f, parent_const_name)
        end

        find_proto_service_definitions.each do |f|
          parent_const_name = File.basename(f).gsub(".", "::").split("::")[0].classify
          load_and_watch(f, parent_const_name)
        end

        find_grpc_model_files.each do |f|
          parent_const_name = File.basename(f).gsub(".", "::").split("::")[0].classify
          load_and_watch(f, parent_const_name)
        end

        find_grpc_service_files.each do |f|
          parent_const_name = File.basename(f).gsub(".", "::").split("::")[0].classify
          load_and_watch(f, parent_const_name)
        end

        @@loaded = true
      end

      def clear_dependencies!
        @@loaded = false
      end

      def load_and_watch(file_path, const_name)
        watch_file_and_dir(file_path) unless self.cache_classes?

        ActiveSupport::Dependencies.require_or_load(file_path, const_name.to_sym)
      end

      def watch_file_and_dir(file_path)
        dir_path = File.dirname(file_path)

        ::Rails.application.config.watchable_dirs[dir_path] = [:rb]
        unless ::Rails.application.config.watchable_files.include?(file_path)
          ::Rails.application.config.watchable_files.concat([file_path])
        end
      end
    end
  end
end
