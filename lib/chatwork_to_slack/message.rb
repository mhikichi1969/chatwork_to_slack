require_relative "../chatwork_to_slack/filters/dtext"
require_relative "../chatwork_to_slack/filters/emoji"
require_relative "../chatwork_to_slack/filters/picon"
require_relative "../chatwork_to_slack/filters/pre"
require_relative "../chatwork_to_slack/filters/reply"
require_relative "../chatwork_to_slack/filters/quote"

module ChatWorkToSlack
  class Message
    attr_reader :channel, :users
    def initialize(args)
      chatwork_message = args[:message]
      @time = chatwork_message[0]
      @name = chatwork_message[1]
      @text = chatwork_message[2]
      @users = args[:users]
      @channel = args[:channel]
      @chatwork_users = args[:chatwork_users]
    end

    def time
      Time.parse(@time).to_i
    end

    def name
      #print @name,"\n"
      if @name.match(/\A[\d]+\Z/)
        user = @users.find{|u| u[:chatwork_account_id] == @name.to_i}
      else
        user = @users.find{|u| u[:chatwork_name] == @name}
      end
      #print user,"\n"

      if !!user
        user[:slack_name] || @name
      else
        @name
      end
    end

    def text
      #print "\nMESSAGE ",@text,"\nMESSAGE END\n"
      options = { users: users }
      filters.inject(@text) {|text, filter| filter.call(text, options)}
      #filters.inject(@text) {|text, filter| print filter}
    end

    def filters
      [
        ChatWorkToSlack::Filters::Dtext,
        ChatWorkToSlack::Filters::Emoji,
        ChatWorkToSlack::Filters::Picon,
        ChatWorkToSlack::Filters::Pre,
        ChatWorkToSlack::Filters::Reply,
        ChatWorkToSlack::Filters::Quote,
      ]
    end

    def to_slack
      [time, channel, name, text]
    end
  end
end
