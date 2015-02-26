require 'twitter'
require 'rufus-scheduler'

puts "going to stream"
stream = Twitter::Streaming::Client.new do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.access_token = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.access_token = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

scheduler = Rufus::Scheduler.new

stream.user do |ev|
  if ev.is_a? Array # Initial array sent on first connection
    puts "Online!"
  elsif ev.is_a? Twitter::Tweet
    text = "#{ev.user.screen_name}: #{ev.text}"
    #puts "It's a tweet! #{text}"
    scheduler.every '1h', :first_in => '1m', :times => 48 do
      status = client.status ev
      if not status.is_a? Twitter::Tweet
        puts text
        # FIXME unschedule
      end
    end
  elsif ev.is_a? Twitter::Streaming::StallWarning
    warn "Falling behind!"
  elsif ev.is_a? Twitter::Streaming::DeletedTweet
    puts "FIXME we should raise the event right now!"
  else
    puts "something else"
    puts ev
  end
end
