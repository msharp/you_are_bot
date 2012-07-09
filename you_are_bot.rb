require 'twitter'

class YouAreBot

  attr_accessor :consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret, :troll_log_dir, :troll_log_file, :trolls_per_min

  def initialize
    cfg = get_yaml

    @consumer_key = cfg['twitter']['consumer_key']
    @consumer_secret = cfg['twitter']['consumer_secret']
    @oauth_token = cfg['twitter']['oauth_token']   
    @oauth_token_secret = cfg['twitter']['oauth_token_secret']

    @troll_log_dir = "#{File.dirname(__FILE__)}/trolled"    
    @troll_log_file = "#{@troll_log_dir}/trolled.log"

    @trolls_per_min = cfg['trolls_per_min'].to_i  
  end

  def log_troll(u)
    %x{echo '#{u}' >> #{@troll_log_file}}
  end

  def was_trolled(u)
    %x{egrep -r '^#{u}$' #{@troll_log_dir}/* | wc -l}.strip().to_i > 0
  end

  def get_yaml
    YAML.load(File.new("#{File.dirname(__FILE__)}/config.yml"))
  end

  def to_s
    out = <<END
consumer_key = #{@consumer_key}
consumer_secret = #{@consumer_secret}
oauth_token = #{@oauth_token}
oauth_token_secret = #{@oauth_token_secret}
END
    out
  end
end

troll_response = "don't you mean \"you are\"? You can use an apostrophe to write these two words as \"you're\", which is a homonym of \"your\"."

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
res.reject!{|r|r.text =~ /^RT/}

# don't troll the same user repeatedly
res.reject!{|r|yab.was_trolled(r.from_user)}
  
# when using 'your' in a sentence which should use you're
res.select{|r|r.text =~ / your an? /}.each do |t|  

 #puts "got: #{t.inspect}"

  results[t.from_user] = {
    :id => t.id, 
    :text => t.text, 
    :from => t.from_user
  } unless results.has_key?(t.from_user)

end

# release the troll
yab.trolls_per_min.times do 

  trollee = results.shift
  user = trollee[0]
  tweet = trollee[1]

  puts "now trolling: @#{user} for tweet: #{tweet[:text]}"

  Twitter.update("@#{user} #{troll_response}", :in_reply_to_status_id => tweet[:id])
  yab.log_troll(user)

end
