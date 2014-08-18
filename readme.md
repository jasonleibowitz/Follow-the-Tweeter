# Follow the Tweeter


### Project Description
---

Follow the Tweeter aims to help people decide who to follow by analyzing tweet statistics. The app looks at any inputted users last 200 tweets to gauge how often they tweet per day, percentage of retweets in their feed, percentage of tweets with links and more. 

If you have any feature requests feel free to reach out to me [@jasonleibowitz](twitter.com/jasonleibowitz).

### Release Notes
---
#### v.0.0.4

Added support for an interactive chart on the results page. The chart graphs the last 30 days of tweets on a line chart so it is easy to visually view a user's activity.

#### v.0.0.3

The tweets per day algorithm has been updated to take into account days when the user does not tweet. This results in a more accurate tweets per day number with two decimal places. 

##### v.0.0.2

FtT now handles errors. If you input a twitter account that is either protected or suspended the app won't crash and will notify you. 

FtT also detects how many tweets include links vs simple text content so you can see which tweeters are directing you to new and interesting content.

##### v 0.0.1

App launched!

### Links
---

* [Live Site](followthetweeter.herokuapp.com)
* [GitHub](https://github.com/jasonleibowitz/Follow-the-Tweeter)

### Technologies Used
---

* APIs
	* [Twitter API](https://dev.twitter.com/)
* Gems
	* [Ruby Twitter Wrapper](https://github.com/sferik/twitter)
* Core Technologies
	* [Ruby on Rails](http://rubyonrails.org/)
	* [jQuery](http://jquery.com/)
	* [Chart.js](http://www.chartjs.org/)