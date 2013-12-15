require "basic_logging/version"

##
# A basic logging library providing different file output 
# formats and suppression of log messages based on 
# defined log level.
module BasicLogging

	##
	# The LoggerFactory class contains the factory method
	# to instantiate a Logger object. This is the preferred
	# method of creating a Logger object.
	#   logger = BasicLogging::LoggerFactory.create(:text)
	class LoggerFactory
		require 'fileutils'

		attr_accessor :log_file

		##
		# The factory method takes a log file type argument, 
		# either :text, :csv or :html anything else will 
		# log to STDOUT. The method also takes an optional
		# file argument, giving a path and filename (without 
		# a file extension) to save the log file to. The default
		# file location is <tt>log/basic_log<.ext></tt>.
		#
		# The following code will create a HTML logger and store 
		# the log file in <tt>log/reports/main-log.html</tt>
		#   logger = BasicLogging::LoggerFactory.create(:html, 'log/reports/main-log')
		def self.create(file_type, file=nil)
			# check for log file arg, if nil use default
			log_file = file
			if log_file.nil?
				log_file = 'log/basic_log'
			end
			logger = nil
			# create any directories need in log_file path
			FileUtils.makedirs(File.split(log_file)[0])

			# determine the type of logger required
			# and add an appropriate file extension
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

	##
	# The base logging class provides the logging interface
	# and basic functionality regarding log suppression. All 
	# other loggers inherit from Logger.
	class Logger
		attr_accessor :level

		# Log suppression levels constants
		ERROR = 1
		WARN = 2
		INFO = 3
		DEBUG = 4

		##
		# The default log level is WARN
		def initialize(log_level=WARN)
			@level = log_level.to_i
		end

		##
		# The main log class. Determines whether
		# a particular log message should be recorded 
		# depending on the current log level setting.
		# The message argument can be simply a string or 
		# can be used with optional +*args+ to create a 
		# format string like that used in +sprintf+.
		#   # a simple log message
		#   logger.log(BasicLogging::Logger::INFO, 'a simple message')
		#   # a formatted log message
		#   logger.log(BasicLogging::Logger::INFO, 
		#	      '%d: a %s formatted message', 'simple', 23)
		# Using the formatted style provides better performance over 
		# string interpolation and string concatenation when the log 
		# message is being surpressed.
		def log(log_level, message, *args)
			if @level >= log_level.to_i then
				begin
					# substitute args into message according to message format
					formatted_message = message % args
					# get the string equivalent of the message's log level
					level_string = level_to_string(log_level)
					# write the log message
					write_to_log(level_string, formatted_message)
				rescue ArgumentError, TypeError
					# catch any errors associated with formatting and log them
					write_to_log('ERROR', "formatting log message string - #{message}")
				end
			end
		end

		##
		# An synonym for and error log message
		def error(message, *args)
			log(ERROR, message, *args)
		end

		##
		# An synonym for and warning log message
		def warn(message, *args)
			log(WARN, message, *args)
		end

		##
		# An synonym for and info log message
		def info(message, *args)
			log(INFO, message, *args)
		end

		##
		# An synonym for and debug log message
		def debug(message, *args)
			log(DEBUG, message, *args)
		end
		
		##
		# Resets the current log
		def reset
			# nothing to reset
		end

		private

			# create a timestamp for current time
			def timestamp
				tnow = Time::now
				tnow.strftime("%F %T")
			end

			# does actual work of writing the log, to STDOUT
			def write_to_log(level, message)
				puts "[#{timestamp}] #{level}: #{message.to_s}"
			end

			# converts log level to a string
			def level_to_string(level)
				str = ''
				case level
					when ERROR then str = 'ERROR'
					when WARN then str = 'WARN'
					when INFO then str = 'INFO'
					when DEBUG then str = 'DEBUG'
					else str = 'UNKNOWN'
				end
				return str
			end
	end

	##
	# FileLogger sends log message to a text file.
	class FileLogger < Logger

		# takes file path and optional log level
		def initialize(file, level=WARN)
			super(level)
			@log_file = file
			# create the log file
			File.open(@log_file, 'a').close
		end

		# sends log for writing
		def write_to_log(level, message)
			write_to_file("[#{timestamp}] #{level}: #{message.to_s}\n")
		end

		# reset the log, delete the file
		def reset
			File.delete(@log_file) if File.exists?(@log_file)
		end

		private

			# actually writes to the file, uses 
			# file locks to prevent concurrent 
			# access while writing
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

	##
	# CsvFileLogger inherits from FileLogger adn sends log 
	# message to a text file in CSV format.
	class CsvFileLogger < FileLogger

		def initialize(file)
			super(file)
		end

		# sends csv formatted message to parents write_to_file
		def write_to_log(level, message)
			write_to_file("#{timestamp},#{level},#{message.to_s}\n")
		end

	end

	##
	# HtmlFileLogger inherits from FileLogger adn sends log 
	# message to a html formatted file.
	class HtmlFileLogger < FileLogger

		def initialize(file)
			super(file)
		end

		def write_to_log(level, message)
			write_to_file("#{create_html(level, message)}\n")
		end

		private

			# format the message in a html syntax
			def create_html(level, message)
				"<div class=\"#{level.downcase}\"><span class=\"level\">#{level}</span>" +
				"<span class=\"datetime\">#{timestamp}</span>" + 
				"<span class=\"message\">#{message}</span></div>"
			end

	end

end
