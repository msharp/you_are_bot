
class YouAreBot

  attr_accessor :consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret, :troll_log_dir, :troll_log_file, :trolls_per_min

  def initialize
    cfg = YAML.load(File.new("#{File.dirname(__FILE__)}/config.yml"))

    @consumer_key = cfg['twitter']['consumer_key']
    @consumer_secret = cfg['twitter']['consumer_secret']
    @oauth_token = cfg['twitter']['oauth_token']   
    @oauth_token_secret = cfg['twitter']['oauth_token_secret']

    @troll_messages = cfg['messages']

    @troll_log_dir = "#{File.dirname(__FILE__)}/trolled"    
    @troll_log_file = "#{@troll_log_dir}/trolled.log"
    @retweet_log_file = "#{@troll_log_dir}/retweeted.log"

    # ensure log files exist
    %x{touch #{@troll_log_file}}
    %x{touch #{@retweet_log_file}}
  end

  def troll_response
    @troll_messages[rand(@troll_messages.size)]
  end

  def log_troll(u)
    %x{echo '#{u}' >> #{@troll_log_file}}
  end

  def log_retweet(t)
    %x{echo '#{t}' >> #{@retweet_log_file}}
  end

  def was_trolled(u)
    %x{egrep -r '^#{u}$' #{@troll_log_file}* | wc -l}.strip().to_i > 0
  end

  def was_retweeted(t)
    %x{egrep -r '^#{t}$' #{@retweet_log_file}* | wc -l}.strip().to_i > 0
  end

end

