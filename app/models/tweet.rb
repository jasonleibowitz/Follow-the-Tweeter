class Tweet

  attr_accessor :username, :timeline, :user, :error

  def initialize(username)
    @username = username
    begin
      @timeline = Tweet.api_call.user_timeline(username, {excluse_replies: true, include_rts: true, count: 200})
      @error = false
    rescue Twitter::Error::Unauthorized
      @error = 'This twitter account is protected. Follow the Tweeter can only analyze unprotected accounts.'
    end
    begin
      @user = Tweet.api_call.user(username)
    rescue Twitter::Error::Forbidden
      @error = 'This twitter account appears to be suspended.'
    end
  end

    def self.api_call
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.consumer_key
        config.consumer_secret     = Rails.application.secrets.consumer_secret
        config.access_token        = Rails.application.secrets.access_token
        config.access_token_secret = Rails.application.secrets.access_token_secret
      end
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
    Hash[tweets_per_day.sort]
  end

  def calculate_average_tweets_per_day
    tpd_hash_including_days_with_no_tweets = self.account_for_dates_with_no_tweets.to_h
    average = 0
    tpd_hash_including_days_with_no_tweets.each_pair do |date, value|
      average += value
    end
    ((average * 1.0) / (tpd_hash_including_days_with_no_tweets.length * 1.0))
  end

  def self.does_tweet_contain_url?(string)
    result = false
    string.split(' ').each do |word|
      if /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/.match(word)
        result = true
      end
    end
    result
  end

  def calculate_tweets_with_links
    tweets_with_url = 0
    self.timeline.each do |tweet|
      if Tweet.does_tweet_contain_url?(tweet.text)
        tweets_with_url += 1
      end
    end
    tweets_with_url
  end

  def account_for_dates_with_no_tweets
    full_date_range = []
    sorted_tweet_hash = self.create_tweets_per_day_hash
    first_tweet_date = sorted_tweet_hash.first[0]
    last_tweet_date = sorted_tweet_hash.keys[sorted_tweet_hash.length - 1]

    # create full date range and add it to array
    (first_tweet_date..last_tweet_date).each { |date| full_date_range << date }
    full_date_range.each do |date_to_check|
      if sorted_tweet_hash.include? date_to_check
      else
        sorted_tweet_hash[date_to_check] = 0
      end
    end
    sorted_tweet_hash.sort
  end

end
