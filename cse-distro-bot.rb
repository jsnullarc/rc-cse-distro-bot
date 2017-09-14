require 'slack-ruby-bot'

module CseDistroBot
  class Bot < SlackRubyBot::Bot
    cses = []
    current_robin_index = 0
    muted = false

    command 'list roster' do |client, data, match|
      response = 'There are currently no CSEs in the roster'
      if cses.size.nonzero?
        list = cses.each_with_index.map { |cse, index| "<@#{cse}> [index: #{index}]" }
        response = "The current CSE roster is: #{list.join(' | ')}"
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

    command 'clear roster' do |client, data, match|
      cses = []
      client.say(channel: data.channel, text: "I've cleared out the roster list, the roster has NO MEMBERS. Please add one for distro")
    end

    match /remove from roster:(?<index>\d*)/ do |client, data, match|
      cse_index = match[:index].to_i
      if cse_index < cses.size
        user = cses[cse_index]
        cses.delete_at(cse_index)

        client.say(channel: data.channel, text: "I removed <@#{user}> from the roster")
      else
        client.say(channel: data.channel, text: "Uhmm.. that index doesn't exist. Hehe.. :sweat_smile:")
      end
    end

    match /start with:(?<index>\d*)/ do |client, data, match|
      cse_index = match[:index].to_i
      if cse_index < cses.size
        current_robin_index = cse_index

        client.say(channel: data.channel, text: "K. Our rounds will now start from <@#{cses[cse_index]}>")
      else
        client.say(channel: data.channel, text: "Uhmm.. that index doesn't exist. Hehe.. :sweat_smile:")
      end
    end

    command 'start with me' do |client, data, match|
      cses.each_with_index do |cse, index|
        if cse == cses[current_robin_index]
          current_robin_index = index
          break
        end
      end

      client.say(channel: data.channel, text: "K. Our rounds will now start from <@#{data.user}>")
    end

    command 'next cse' do |client, data, match|
      if (current_robin_index + 1) < cses.size
          client.say(channel: data.channel, text: "Next case will be assigned to <@#{cses[current_robin_index + 1]}>")
        else
          client.say(channel: data.channel, text: "Next case will be assigned to <@#{cses[0]}>")
        end
    end

    command 'mute' do |client, data, match|
      muted = true

      client.say(channel: data.channel, text: "Okay.. :( I won't distribute anymore.. Please unmute me later..")
    end

    command 'unmute' do |client, data, match|
      muted = false

      client.say(channel: data.channel, text: "Yes! Please update my circulation by saying `@cse_distro_bot start with me`!")
    end

    match /^Open email case from .+#(?<case_no>\w*)/ do |client, data, match|
      if muted == false
        if cses.size.zero?
          cse_to_handle = "Someone here"
        else
          cse_to_handle = "<@#{cses[current_robin_index]}>"
        end

        client.say(channel: data.channel, text: "#{cse_to_handle} please own this case: https://referralcandy.desk.com/agent/case/#{match[:case_no]}")

        if (current_robin_index + 1) < cses.size
          current_robin_index = current_robin_index + 1
        else
          current_robin_index = 0
        end
      end
    end

    help do
      title 'CSE Distro Bot'
      desc 'This bot helps us CSEs distribute the cases in a round-robin fashion. If you have any suggestions, recommendations, or bug reports, please ping Jason.'

      command 'list roster' do
        desc 'View the current CSE roster that will be handling cases'
      end

      command 'let me join' do
        desc "Mention me with this command and I'll add you to the current roster."
      end

      command 'reset roster' do
        desc 'Clear the roster and add yourself automatically. Useful when everyone else is on leave.'
      end

      command 'next cse' do
        desc "I'll tell you who the next case will be assigned to"
      end

      command 'start with me' do
        desc "Tells me to start the circulation from you."
      end

      command 'start with:[index]' do
        desc "Tells me to start the circulation from the selected roster member index."
      end

      command 'mute' do
        desc "If you do not need me to distribute, just say this to me"
      end

      command 'unmute' do
        desc "Once you need me to distribute again, just unmute me. Don't forget to utilize the `start with me` command if necessary."
      end

      command 'remove from roster:[index]' do
        desc "Remove a specific user from the roster using their index listed in `list roster`"
      end
    end
  end
end
