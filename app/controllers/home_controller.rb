class HomeController < ApplicationController

  def welcome

  end

  def results
    username = params[:q]
    @twitter_user = Tweet.new(username)
    unless @twitter_user.error
      @name = @twitter_user.user.name
      @followers = @twitter_user.user.followers_count
      @bio = @twitter_user.user.description
      @total_num_tweets = @twitter_user.total_number_of_tweets
      @first_recorded_tweet = @twitter_user.oldest_tweet
      @num_retweets = @twitter_user.number_of_retweets
      @retweet_percentage = ((( @num_retweets * 1.0 ) / ( @total_num_tweets * 1.0 )) * 100).round
      @tweets_per_day = @twitter_user.calculate_average_tweets_per_day.round(2)
      @tweets_with_links = @twitter_user.calculate_tweets_with_links
      @tweet_with_links_percentage = (@tweets_with_links * 1.0) / (@total_num_tweets * 1.0) * 100
    else
      flash[:error] = @twitter_user.error
      redirect_to root_path
    end
  end

end
