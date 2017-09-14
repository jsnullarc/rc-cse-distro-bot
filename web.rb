require 'sinatra/base'

module CseDistroBot
  class Web < Sinatra::Base
    get '/' do
      'Distribution is key.'
    end
  end
end

SlackRubyBot::Client.logger.level = Logger::WARN

SlackRubyBot.configure do |config|
  config.logger = Logger.new("logs/bot.log", "daily")
end

foreman start
