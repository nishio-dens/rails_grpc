module RailsGrpc
  module Rails
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "tasks/protoc.rake"
      end
    end
  end
end
