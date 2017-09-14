require 'slack-ruby-bot'

module CseDistroBot
  class Bot < SlackRubyBot::Bot
    cses = []
    current_robin_index = 0

    command 'list roster' do |client, data, match|
      response = 'There are currently no CSEs in the roster'
      if cses.size.nonzero?
        list = cses.map { |cse| "<@#{cse}>, " }
        response = "The current CSE roster is: #{list.join(', ')}"
      end

      client.say(channel: data.channel, text: response)
    end

    command 'let me join' do |client, data, match|
      response = "<@#{data.user}>, you have been added to the roster"
      if cses.include? data.user
        response = "<@#{data.user}>, you are already in the roster"
      else
        cses << data.user
      end

      client.say(channel: data.channel, text: response)
    end

    command 'reset roster' do |client, data, match|
      cses = []
      cses << data.user
      client.say(channel: data.channel, text: "I've cleared out the roster list and added you as a member, <@#{data.user}>")
    end

    command 'start with me' do |client, data, match|
      cses.each_with_index do |cse, index|
        if cse == cses[current_robin_index]
          current_robin_index = index
          break
        end
      end

      client.say(channel: data.channel, text: "K. Our rounds will now start with <@#{data.user}>")
    end

    match /^Open email case from .+#(?<case_no>\w*)/ do |client, data, match|
      cse_to_handle = "<@#{cses[current_robin_index]}>"
      if (current_robin_index + 1) < cses.size
        current_robin_index = current_robin_index + 1
      else
        current_robin_index = 0
      end

      cse_to_handle = 'Someone <@here>' if cses.size.zero?

      client.say(channel: data.channel, text: "#{cse_to_handle} (#{current_robin_index}) please own this case: https://referralcandy.desk.com/agent/case/#{match[:case_no]}")
    end
  end
end
