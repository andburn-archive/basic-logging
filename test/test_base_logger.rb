require 'test/unit'

require 'basic_logging'

class TestBaseLogger < Test::Unit::TestCase

	def setup
		@debug_level = BasicLogging::Logger::DEBUG
		@logger = BasicLogging::Logger.new(@debug_level)
		@simple_message = 'a simple log message'
		@format_string = '%02d - a more %s log message with %d formatting'
		@format_args = [2, 'complicated', 5]
		@format_message = '02 - a more complicated log message with 5 formatting'
	end

	def test_for_logger_interface
		assert_respond_to(@logger, :log)
		assert_respond_to(@logger, :error)
		assert_respond_to(@logger, :warn)
		assert_respond_to(@logger, :info)
		assert_respond_to(@logger, :debug)
		assert_respond_to(@logger, :reset)
	end

	def test_log_method
		out, err = capture_io do
			@logger.log(@debug_level, @simple_message)
			@logger.log(@debug_level, @format_string, @format_args[0], @format_args[1], @format_args[2])
		end
		assert(format_is_correct?('DEBUG: ', @simple_message, out.chomp))
		assert(format_is_correct?('DEBUG: ', @format_message, out.chomp))
	end

	def test_log_level_methods_with_simple_message
		out, err = capture_io do
			@logger.error(@simple_message)
			@logger.warn(@simple_message)
			@logger.info(@simple_message)
			@logger.debug(@simple_message)
		end
		assert(format_is_correct?('ERROR: ', @simple_message, out))
		assert(format_is_correct?('WARN: ', @simple_message, out))
		assert(format_is_correct?('INFO: ', @simple_message, out))
		assert(format_is_correct?('DEBUG: ', @simple_message, out))
	end

	def test_log_level_methods_with_formatted_message
		out, err = capture_io do
			@logger.error(@format_string, @format_args[0], @format_args[1], @format_args[2])
			@logger.warn(@format_string, @format_args[0], @format_args[1], @format_args[2])
			@logger.info(@format_string, @format_args[0], @format_args[1], @format_args[2])
			@logger.debug(@format_string, @format_args[0], @format_args[1], @format_args[2])
		end
		assert(format_is_correct?('ERROR: ', @format_message, out))
		assert(format_is_correct?('WARN: ', @format_message, out))
		assert(format_is_correct?('INFO: ', @format_message, out))
		assert(format_is_correct?('DEBUG: ', @format_message, out))
	end

	def test_log_level_error
		@logger.level = BasicLogging::Logger::ERROR
		out, err = capture_io do
			@logger.error(@simple_message)
			@logger.warn(@simple_message)
			@logger.info(@simple_message)
			@logger.debug(@simple_message)
		end

		assert(format_is_correct?('ERROR: ', @simple_message, out))
		
		refute(format_is_correct?('WARN: ', @simple_message, out))
		refute(format_is_correct?('INFO: ', @simple_message, out))
		refute(format_is_correct?('DEBUG: ', @simple_message, out))
	end

	def test_log_level_warn
		@logger.level = BasicLogging::Logger::WARN
		out, err = capture_io do
			@logger.error(@simple_message)
			@logger.warn(@simple_message)
			@logger.info(@simple_message)
			@logger.debug(@simple_message)
		end

		assert(format_is_correct?('ERROR: ', @simple_message, out))
		assert(format_is_correct?('WARN: ', @simple_message, out))

		refute(format_is_correct?('INFO: ', @simple_message, out))
		refute(format_is_correct?('DEBUG: ', @simple_message, out))
	end

	def test_log_level_info
		@logger.level = BasicLogging::Logger::INFO
		out, err = capture_io do
			@logger.error(@simple_message)
			@logger.warn(@simple_message)
			@logger.info(@simple_message)
			@logger.debug(@simple_message)
		end

		assert(format_is_correct?('ERROR: ', @simple_message, out))
		assert(format_is_correct?('WARN: ', @simple_message, out))
		assert(format_is_correct?('INFO: ', @simple_message, out))

		refute(format_is_correct?('DEBUG: ', @simple_message, out))
	end

	# Test helper methods
	private

		def format_is_correct?(level, message, output)
			# regex pattern matches timestamp like '[2013-01-01 22:00:00]'
			# plus error level and message
			output.chomp =~ /^\[\d{4}\-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] #{level}#{message}$/
		end

end