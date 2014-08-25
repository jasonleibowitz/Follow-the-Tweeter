class Tweet

  attr_accessor :username, :timeline, :user, :error

  def initialize(username)
    @username = username
    begin
      @timeline = Tweet.api_call.user_timeline(username, {excluse_replies: true, include_rts: true, count: 200})
      @error = false
    rescue Twitter::Error::Unauthorized
      @error = 'This twitter account is protected. Follow the Tweeter can only analyze unprotected accounts.'
    rescue Twitter::Error::NotFound
      @error = 'There is no twitter user with that username. Please check that you typed the username correctly.'
    end
    begin
      @user = Tweet.api_call.user(username)
    rescue Twitter::Error::Forbidden
      @error = 'This twitter account appears to be suspended.'
    rescue Twitter::Error::NotFound
      @error = 'There is no twitter user with that username. Please check that you typed the username correctly.'
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

  def create_javascript_friendly_tpd_hash
    tpd_hash = self.create_tweets_per_day_hash
    keys = []
    values = []
    tpd_hash.each do |k, v|
      month = k.strftime "%b"
      day = k.strftime "%e"
      keys.push(month + " " + day)
      values.push(v)
    end
    [keys.last(30), values.last(30)]
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

  def calculate_similarity_scores
    similarity_rating_array = 0
    num_of_repeated_tweets = 0
    num_of_similar_tweets = 0
    timeline_without_rts = self.timeline
    timeline_without_rts.each do |tweet|
      if tweet.reply?
        timeline_without_rts.delete(tweet)
      end
    end
    timeline_without_rts.combination(2).each do |first_tweet, second_tweet|      similarity_score = first_tweet.text.similar(second_tweet.text)
      if similarity_score == 100
        similarity_rating_array += similarity_score
        num_of_repeated_tweets += 1
      elsif (similarity_score > 75)
        similarity_rating_array += similarity_score
        num_of_similar_tweets += 1
      else
        similarity_rating_array += similarity_score
      end
    end
    similarity_rating = similarity_rating_array / timeline_without_rts.combination(2).to_a.length
    # binding.pry
    return [similarity_rating.round(2), num_of_repeated_tweets, num_of_similar_tweets]
  end

  def calculate_followbility_score(retweet_percentage, tweet_with_link_percentage, repeated_tweets, similar_tweets, tweets_per_day)
    followbility_score = 0
    # calculate tweet_per_day, which can be up to 3 points
    if (tweets_per_day > 0.3) && (tweets_per_day < 5.0)
      followbility_score += 3
    end
    # calculate repeated tweets, which can be up to 2 points
    if repeated_tweets < 10
      followbility_score += 2
    elsif (repeated_tweets > 10) && (repeated_tweets < 20)
      followbility_score += 1
    end
    # calculate link percentage, which can be up to 2 points
    if tweet_with_link_percentage >= 70
      followbility_score += 3
    elsif tweet_with_link_percentage >= 40
      followbility_score += 2
    elsif tweet_with_link_percentage >= 25
      followbility_score += 1
    end
    # calculate rt percentage, which can be up to 1 point
    if retweet_percentage <= 25
      followbility_score += 1
    end
    # calculate similar tweets, which can be up to 1 point
    if similar_tweets <= 25
      followbility_score += 1
    end
    followbility_score
  end

end
