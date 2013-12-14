require "basic_logging/version"

module BasicLogging
  
	class LogFactory

		def self.create_logger
			Logger.new
		end

	end

	# Basic Logger class
	class Logger
		attr_accessor :level

		# Log Levels
		ERROR = 1
		WARN = 2
		INFO = 3
		DEBUG = 4
		FINE = 5

		def initialize
			@level = FINE
		end

		def log(message)
			write_to_log(message) if @level >= FINE
		end

		def logf(format_string, *args)
			write_to_log(format_string % args)
		end

		def error(message)
			write_to_log('ERROR: ' + message) if @level >= ERROR
		end

		def warn(message)
			write_to_log('WARN: ' + message) if @level >= WARN
		end

		def info(message)
			write_to_log('INFO: ' + message) if @level >= INFO
		end

		def debug(message)
			write_to_log('DEBUG: ' + message) if @level >= DEBUG
		end

		def fine(message)
			log(message)
		end

		def timestamp
			tnow = Time::now
			tnow.strftime("[%F %T]")
		end

		private

			def write_to_log(message)
				puts "#{timestamp} #{message.to_s}"
			end
	end

	class FileLogger < Logger

		def initialize(file)
			@@log_file = file
			f = File.new(@@log_file, 'w')
			f.close
		end

		def log(message)
			File.open(@@log_file, 'w') do |f|
				f.write "#{timestamp} #{message}\n"
			end
		end

	end

end
