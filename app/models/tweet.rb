class Tweet

  attr_accessor :username, :timeline, :user

  def initialize(username)
    @username = username
    @timeline = Tweet.api_call.user_timeline(username, {excluse_replies: true, include_rts: true, count: 200})
    @user = Tweet.api_call.user(username)
  end

    def self.api_call
    client = Twitter::REST::Client.new do |config|
      # config.consumer_key        = Rails.application.secrets.consumer_key
      # config.consumer_secret     = Rails.application.secrets.consumer_secret
      # config.access_token        = Rails.application.secrets.access_token
      # config.access_token_secret = Rails.application.secrets.access_token_secret
      config.consumer_key        = ENV["CONSUMER_KEY"]
      config.consumer_secret     = ENV["CONSUMER_SECRET"]
      config.access_token        = ENV["ACCESS_TOKEN"]
      config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
    end
    # client.user_timeline(username, {excluse_replies: true, include_rts: true, count: 200})
  end

  def total_number_of_tweets
    self.timeline.length
  end

  def oldest_tweet
    self.create_tweets_per_day_hash.first[0]
  end

  def number_of_retweets
    retweet_counter = 0
    self.timeline.each do |tweet|
      if tweet.retweeted_tweet?
        retweet_counter += 1
      end
    end
    return retweet_counter
  end

  def create_tweets_per_day_hash
    tweets_per_day = {}
    self.timeline.each do |tweet|
      unless tweet.reply?
        if tweets_per_day[tweet.created_at.to_date] == nil
          tweets_per_day[tweet.created_at.to_date] = 1
        else
          tweets_per_day[tweet.created_at.to_date] += 1
        end
      end
    end
    sorted_tweets_per_day = Hash[tweets_per_day.sort]
  end

  def calculate_average_tweets_per_day
    tpd_hash = self.create_tweets_per_day_hash
    average = 0
    tpd_hash.each_pair do |date, value|
      average += value
    end
    average_tweets_per_day = ((average * 1.0) / (tpd_hash.length * 1.0)).round
  end

end
