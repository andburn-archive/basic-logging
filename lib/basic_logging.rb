require "basic_logging/version"

module BasicLogging

	class LoggerFactory
		require 'fileutils'

		attr_accessor :log_file

		def self.create(file_type, file=nil)
			log_file = file
			if log_file.nil?
				log_file = 'logs/basic_log'
			end
			logger = nil

			FileUtils.makedirs(File.split(log_file)[0])

			case file_type
			when :text
				log_file += '.txt'
				logger = FileLogger.new(log_file)
			when :csv
				log_file += '.csv'
				logger = CsvFileLogger.new(log_file)
			when :html
				log_file += '.html'
				logger = HtmlFileLogger.new(log_file)
			else
				logger = Logger.new
			end

			return logger
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

		def initialize(log_level=WARN)
			@level = log_level.to_i
		end

		def log(log_level, message, *args)
			if @level >= log_level.to_i then
				begin
					formatted_message = message % args
					level_string = level_to_string(log_level)
					write_to_log(level_string, formatted_message)
				rescue ArgumentError, TypeError
					write_to_log('ERROR', "formatting log message string - #{message}")
				end
			end
		end

		def error(message, *args)
			log(ERROR, message, *args)
		end

		def warn(message, *args)
			log(WARN, message, *args)
		end

		def info(message, *args)
			log(INFO, message, *args)
		end

		def debug(message, *args)
			log(DEBUG, message, *args)
		end
		
		def reset
			# do nothing in this mode
		end

		private

			def timestamp
				tnow = Time::now
				tnow.strftime("%F %T")
			end

			def write_to_log(level, message)
				puts "[#{timestamp}] #{level}: #{message.to_s}"
			end

			def level_to_string(level)
				str = ''
				case level
					when ERROR then str = 'ERROR'
					when WARN then str = 'WARN'
					when INFO then str = 'INFO'
					when DEBUG then str = 'DEBUG'
				end
				return str
			end
	end

	class FileLogger < Logger

		def initialize(file, level=WARN)
			super(level)
			@log_file = file
			# create the log file
			File.open(@log_file, 'a').close
		end

		def write_to_log(level, message)
			write_to_file("[#{timestamp}] #{level}: #{message.to_s}\n")
		end

		def reset
			File.delete(@log_file) if File.exists?(@log_file)
		end

		private

			def write_to_file(message)
				if File.exist?(@log_file)
					File.open(@log_file, 'a') do |f|
						begin
							f.flock(File::LOCK_EX)
							f.write message
						ensure
							f.flock(File::LOCK_UN)
						end
					end
				end
			end

	end

	class CsvFileLogger < FileLogger

		def initialize(file)
			super(file)
		end

		def write_to_log(level, message)
			write_to_file("#{timestamp},#{level},#{message.to_s}\n")
		end

	end

	class HtmlFileLogger < FileLogger

		def initialize(file)
			super(file)
		end

		def write_to_log(level, message)
			write_to_file("#{create_html(level, message)}\n")
		end

		private

			def create_html(level, message)
				"<div class=\"#{level.downcase}\"><span class=\"level\">#{level}</span>" +
				"<span class=\"datetime\">#{timestamp}</span>" + 
				"<span class=\"message\">#{message}</span></div>"
			end

	end

end
