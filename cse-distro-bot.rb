require 'slack-ruby-bot'

module CseDistroBot
  class Bot < SlackRubyBot::Bot
    cses = []

    command 'list roster' do |client, data, match|
      response = 'There are currently no CSEs in the roster.'
      if cses.size.nonzero?
        response = "The current CSE roster is: #{cses.join(', ')}"
      end

      client.say(channel: data.channel, text: response)
    end

    command 'list users' do |client, data, match|
      client.say(channel: data.channel, text: client.users.inspect)
    end

    match /^Open email case from .+#(?<case_no>\w*)/ do |client, data, match|
      client.say(channel: data.channel, text: "Someone please own this case: https://referralcandy.desk.com/agent/case/#{match[:case_no]}")
    end
  end
end

# require 'slack-ruby-client'

# module CseDistroBot
#   class Bot < SlackRubyClient
#     Slack.configure do |config|
#       config.token = ENV['SLACK_API_TOKEN']
#     end
#   end
# end
