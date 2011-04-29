$:.push(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))
require "istat"
require "uri"
require "logger"
LOGGER = Logger.new("debug.log")
LOGGER.level = Logger::DEBUG

SERVER = URI.parse(ENV["TEST_SERVER"] || "istat://any:10946@localhost:5109/")
