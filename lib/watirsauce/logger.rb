module WatirSauce
  class << self
    def logger
      @logger ||= create_and_format_logger
    end

    # @return [logger]
    def create_and_format_logger
      logger = Logger.new(STDOUT)
      logger.formatter = proc do |severity, datetime, _, msg|
        "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')} - #{severity}]  #{msg}\n"
      end
      logger
    end
  end
end