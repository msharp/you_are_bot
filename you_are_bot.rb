require 'twitter'

CONSUMER_KEY        = ""
CONSUMER_SECRET     = ""
OAUTH_TOKEN         = ""
OAUTH_TOKEN_SECRET  = ""

TROLL_LOG_DIR       = "#{File.dirname(__FILE__)}/trolled"
TROLLS_PER_MIN      = 1          

def troll_log_file
  "#{TROLL_LOG_DIR}/trolled.log"
end

def log_troll(u)
  %x{echo '#{u}' >> #{troll_log_file}}
end

def was_trolled(u)
  %x{egrep -r '^#{u}$' #{TROLL_LOG_DIR}/* | wc -l}.strip().to_i > 0
end

troll_response = "don't you mean \"you are\"? You can use an apostrophe to write these two words as \"you're\", which is a homonym of \"your\"."


Twitter.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = OAUTH_TOKEN
  config.oauth_token_secret = OAUTH_TOKEN_SECRET
end

results = {}

res = Twitter.search('"your a"', :rpp => 50, :result_type => "recent").results

# throw out retweets
res.reject!{|r|r.text =~ /^RT/}

# don't troll the same user repeatedly
res.reject!{|r|was_trolled(r.from_user)}
  
# when using 'your' in a sentence which should use you're
res.select{|r|r.text =~ / your an? /}.each do |t|  

  results[t.from_user] = {
    :id => t.id, 
    :text => t.text, 
    :from => t.from_user
  } unless results.has_key?(t.from_user)

end

# release the troll
(1..TROLLS_PER_MIN).each do 

  trollee = results.shift
  user = trollee[0]
  tweet = trollee[1]

  Twitter.update("@#{user} #{troll_response}", :in_reply_to_status_id => tweet[:id])
  log_troll(user)

end
