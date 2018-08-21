require "rails"

module RailsGrpc
  class Logger
    class << self
      delegate :debug, :info, :warn, :error, :fatal, to: :logger

      def logger(original_logger)
        return @logger if @logger.present?

        if Rails.env.development? || Rails.env.test?
          std_logger = ActiveSupport::Logger.new(STDOUT)
          multiple_loggers = ActiveSupport::Logger.broadcast(std_logger)
          original_logger.extend(multiple_loggers)
        end

        @logger = original_logger
        @logger
      end
    end
  end
end
