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

res = Twitter.search('"your a"', :rpp => 50, :result_type => "recent").results

# throw out retweets
res.reject!{|r|r.text =~ /(RT|MT)/}

# don't troll the same user repeatedly
res.reject!{|r|yab.was_trolled(r.from_user)}
  
# when using 'your' in a sentence which should use you're
res.select{|r|r.text =~ / your an? /}.each do |t|  

  results[t.from_user] = {
    :id => t.id, 
    :text => t.text, 
    :from => t.from_user
  } unless results.has_key?(t.from_user)

end

# release the troll
if results.size > 0
  
  trollee = results.shift
  user = trollee[0]
  tweet = trollee[1]
  troll_response = yab.troll_response

  puts "trolling: @#{user} for tweet: #{tweet[:text]}"
  puts "troll message: #{troll_response}"

  Twitter.update("@#{user} #{troll_response}", :in_reply_to_status_id => tweet[:id])
  yab.log_troll(user)

end
