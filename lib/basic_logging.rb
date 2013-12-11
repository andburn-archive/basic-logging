require "basic_logging/version"

module BasicLogging
  
	class LogFactory

		def self.create_logger
			BaseLogger.new
		end

	end

	class BaseLogger

		def log(message)
			puts message
		end

	end

	class FileLogger
	
		def log

		end

	end

end
