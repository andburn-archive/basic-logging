require 'test/unit'

require 'basic_logging'

class TestLoggerFactory < Test::Unit::TestCase

	def test_factory_creation
		assert_respond_to(BasicLogging::LoggerFactory, :create)

		logger = BasicLogging::LoggerFactory.create(:basic)
		assert_respond_to(logger, :log)
		assert_respond_to(logger, :error)
		assert_respond_to(logger, :warn)
		assert_respond_to(logger, :info)
		assert_respond_to(logger, :debug)
		assert_respond_to(logger, :reset)

		assert_nothing_raised { logger.reset }
	end

	def test_factory_text_file_creation_default
		logger = BasicLogging::LoggerFactory.create(:text)
		assert_respond_to(logger, :log)
		assert_respond_to(logger, :error)
		assert_respond_to(logger, :warn)
		assert_respond_to(logger, :info)
		assert_respond_to(logger, :debug)
		assert_respond_to(logger, :reset)

		assert(File.exists?('logs/basic_log.txt'))
		assert_nothing_raised { logger.reset }
	end

	def test_factory_csv_file_creation_custom
		logger = BasicLogging::LoggerFactory.create(:csv, 'logs/log')
		assert_respond_to(logger, :log)
		assert_respond_to(logger, :error)
		assert_respond_to(logger, :warn)
		assert_respond_to(logger, :info)
		assert_respond_to(logger, :debug)
		assert_respond_to(logger, :reset)

		assert(File.exists?('logs/log.csv'))
		assert_nothing_raised { logger.reset }
	end

	def test_factory_html_file_creation_custom
		logger = BasicLogging::LoggerFactory.create(:html, 'tmp/logs/loginfo')
		assert_respond_to(logger, :log)
		assert_respond_to(logger, :error)
		assert_respond_to(logger, :warn)
		assert_respond_to(logger, :info)
		assert_respond_to(logger, :debug)
		assert_respond_to(logger, :reset)

		assert(File.exists?('tmp/logs/loginfo.html'))
		assert_nothing_raised { logger.reset }
	end

end