require 'twitter'
require_relative 'you_are_bot'

yab = YouAreBot.new

Twitter.configure do |config|
  config.consumer_key = yab.consumer_key
  config.consumer_secret = yab.consumer_secret
  config.oauth_token = yab.oauth_token
  config.oauth_token_secret = yab.oauth_token_secret
end

results = {}

res = Twitter.search('"@you_are_bot"', :rpp => 5, :result_type => "recent").results

# ensure they have been trolled
res.select!{|r|yab.was_trolled(r.from_user)}
  
# only RT once
res.reject!{|r|yab.was_retweeted(r.id)}
 
# retweet the trollee
res.each do |t|  

  puts "retweeting: @#{t.from_user} "
  puts "tweet #{t.id} : #{t.text} "

  Twitter.retweet(t.id)

  yab.log_retweet(t.id)

  #TODO _ follow user (and don't retweet further)
end
