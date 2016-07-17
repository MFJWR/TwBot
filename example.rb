require './TwBot'

bot = TwBot.new("./config.yml")

bot.setTimerAction(15) do |client|
    client.update(Time.now.strftime("%T"))
end

bot.setReplyAction("@Turai25_Bot") do |client, status|
    client.update("got a reply from @#{status.user.screen_name} at #{Time.now.strftime("%T")}", {:in_reply_to_status_id => status.id})
end

bot.start
