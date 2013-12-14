require 'test/unit'

require 'basic_logging'

class TestCsvFileLogger < Test::Unit::TestCase

	def setup
		# TODO: check how paths work when gem is packed (does test even work then)
		@log_file_name = 'test/data/sample-log.csv'
		File.delete(@log_file_name) if File.exists?(@log_file_name)
		@logger = BasicLogging::CsvFileLogger.new(@log_file_name)
		@message = 'simple message for CsvFileLogger'
	end

	def test_for_logger_interface
		assert_respond_to(@logger, :log)
		assert_respond_to(@logger, :error)
		assert_respond_to(@logger, :warn)
		assert_respond_to(@logger, :info)
		assert_respond_to(@logger, :debug)
		assert_respond_to(@logger, :reset)
	end

	def test_csv_file_logger
		@logger.warn(@message)

		first_line = ''
		assert_nothing_raised do
			File.open(@log_file_name, 'r') do |f|
				first_line = f.readline
			end
		end

		assert(format_is_correct?('WARN', @message, first_line), first_line)
	end

	# Test helper methods
	private

		def format_is_correct?(level, message, output)
			# regex pattern matches timestamp like '[2013-01-01 22:00:00]'
			# plus error level and message
			output.chomp =~ /^\d{4}\-\d{2}-\d{2} \d{2}:\d{2}:\d{2},#{level},#{message}$/
		end


end