require 'test/unit'

require 'basic_logging'

class TestFileLoggingOld

		def setup
		@log_file = 'test/data/sample.log'
		@log_message = 'a sample log message'		
		@logger = BasicLogging::FileLogger.new(@log_file)
	end

	def test_file_logger_file_creation
		assert(File.exists?(@log_file), "file should exist (#{@log_file})")
	end

	def test_file_logger_file_log_message
		@logger.log("filler2")
		@logger.log("filler1")
		@logger.log(@log_message)

		first_line = ''
		assert_nothing_raised do
			File.open(@log_file, 'r') do |f|
				first_line = f.readline
			end
		end
		assert_match(/^\[\d{4}\-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] #{@log_message}$/, first_line.chomp)
	end

	def teardown
		File.delete(@log_file) if File.exists?(@log_file)
	end
end

class TestBasicLogging < Test::Unit::TestCase

	def setup
		@logger = BasicLogging::Logger.new
		@message = 'a sample log message'
	end

	# Test the basic Logger class
	def test_base_logger_has_methods
		# test logger has basic methods
		assert_respond_to(@logger, :log)
		assert_respond_to(@logger, :error)
		assert_respond_to(@logger, :warn)
		assert_respond_to(@logger, :info)
		assert_respond_to(@logger, :debug)
		assert_respond_to(@logger, :fine)
		assert_respond_to(@logger, :timestamp)
	end

	## Test the basic logger message output format
	#    and the log level functionality

	# Test the basic logger log levels, Default = FINE
	def test_base_logger_log_level_default
		# invoke all log methods and capture stdout
		out = capture_all_log_methods(@message, @logger)
		# all should be true		
		assert(format_ok?('ERROR: ', @message, out))
		assert(format_ok?('WARN: ', @message, out))
		assert(format_ok?('INFO: ', @message, out))
		assert(format_ok?('DEBUG: ', @message, out))
		assert(format_ok?('', @message, out))
	end

	# Test the basic logger log levels, ERROR
	def test_base_logger_log_level_error
		@logger.level = BasicLogging::Logger::ERROR
		# invoke all log methods and capture stdout
		out = capture_all_log_methods(@message, @logger)
		
		assert(format_ok?('ERROR: ', @message, out))
		# warn and below should be false
		refute(format_ok?('WARN: ', @message, out))
		refute(format_ok?('INFO: ', @message, out))
		refute(format_ok?('DEBUG: ', @message, out))
		refute(format_ok?('', @message, out))
	end

	# Test the basic logger log levels, WARN
	def test_base_logger_log_level_warn
		@logger.level = BasicLogging::Logger::WARN
		# invoke all log methods and capture stdout
		out = capture_all_log_methods(@message, @logger)
		
		assert(format_ok?('ERROR: ', @message, out))
		assert(format_ok?('WARN: ', @message, out))
		# info and below should be false
		refute(format_ok?('INFO: ', @message, out))
		refute(format_ok?('DEBUG: ', @message, out))
		refute(format_ok?('', @message, out))
	end

	# Test the basic logger log levels, INFO
	def test_base_logger_log_level_info
		@logger.level = BasicLogging::Logger::INFO
		# invoke all log methods and capture stdout
		out = capture_all_log_methods(@message, @logger)
		
		assert(format_ok?('ERROR: ', @message, out))
		assert(format_ok?('WARN: ', @message, out))
		assert(format_ok?('INFO: ', @message, out))
		# debug and below should be false
		refute(format_ok?('DEBUG: ', @message, out))
		refute(format_ok?('', @message, out))
	end

	# Test the basic logger log levels, DEBUG
	def test_base_logger_log_level_debug
		@logger.level = BasicLogging::Logger::DEBUG
		# invoke all log methods and capture stdout
		out = capture_all_log_methods(@message, @logger)
		
		assert(format_ok?('ERROR: ', @message, out))
		assert(format_ok?('WARN: ', @message, out))
		assert(format_ok?('INFO: ', @message, out))
		assert(format_ok?('DEBUG: ', @message, out))
		# default/fine should be false
		refute(format_ok?('', @message, out))
	end

	def test_new_method_format
		format_str = "%d messages about %s at %02d"
		a = c = 2
		b = 'stuff'
		out, err = capture_io { @logger.logf(format_str, a, b, c) }
		assert(format_ok?('', "2 messages about stuff at 02", out.chomp))
	end

	## Test helper methods

	def format_ok?(level, message, output)
		# regex pattern matches timestamp like '[2013-01-01 22:00:00]'
		# plus error level and message
		output.chomp =~ /^\[\d{4}\-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] #{level}#{message}$/
	end

	def capture_all_log_methods(message, logger)
		out, err = capture_io do
			logger.log(@message)
			logger.error(@message)
			logger.warn(@message)
			logger.info(@message)
			logger.debug(@message)
		end
		return out
	end
end