# BasicLogging

A logging library allowing use of different file formats.

## Installation

Add this line to your application's Gemfile:

    gem 'basic_logging', :git => 'https://github.com/andburn/basic_logging.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install basic_logging

## Usage

The factory method is the preferred way of instatiating:
	
	logger = BasicLogging::LoggerFactory.create(:text)
	logger.error('some error message')
