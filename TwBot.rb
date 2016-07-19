require "yaml"
require "twitter"
require "tweetstream"
require "thwait"

class TwBot

    def initialize(yaml)
        keys = YAML.load_file(yaml)

        @client = Twitter::REST::Client.new do |config|
            config.consumer_key        = keys["consumer_key"]
            config.consumer_secret     = keys["consumer_secret"]
            config.access_token        = keys["access_token"]
            config.access_token_secret = keys["access_token_secret"]
        end

        TweetStream.configure do |config|
            config.consumer_key       = keys["consumer_key"]
            config.consumer_secret    = keys["consumer_secret"]
            config.oauth_token        = keys["access_token"]
            config.oauth_token_secret = keys["access_token_secret"]
            config.auth_method = :oauth
        end

        @timeline = TweetStream::Client.new
    end

    def setTimerAction(interval, &block)
        @timerThread = Thread.new do
            before_minute = 0
            loop do
                minute = Time.now.strftime("%M").to_i

                if minute % interval == 0 && before_minute != minute
                    yield(@client)
                    before_minute = minute
                end
                sleep 1
            end
        end
    end

    def setReplyAction(&block)
        @replyThread = Thread.new do
            begin
                @timeline.userstream do |status|
                    if status.text =~ /^@#{@client.settings.screen_name}\s*/
                        yield(@client, status)
                    end
                    sleep 2
                end

            rescue => em
                puts Time.now
                p em
                sleep 2
                retry

            rescue Interrupt
                exit 1
            end
        end
    end

    def start()
        ThreadsWait.all_waits([@timerThread, @replyThread])
    end

end
