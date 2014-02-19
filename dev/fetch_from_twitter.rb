require 'twitter'
require 'yaml'

class TweetFetcher
  attr_reader :twitter_client, :number_of_users, :max_posts_per_user,
              :avail_users, :output_file_rel_path, :fake_friends

  def initialize(opt={ users: 100, max_posts_per_user: 50,
                       user_list: 'usernames.yml',
                       output_file: '../lib/fake_friends/users.yml' } )

    @number_of_users      = opt[:users]
    @max_posts_per_user   = opt[:max_posts_per_user]
    @output_file_rel_path = opt[:output_file]
    @avail_users          = YAML.load_file(opt[:user_list])

    @fake_friends   = {} # users to be stored as FakeFriend objects
    @twitter_client = initialize_twitter_api_client
  end

  # ---
  # prompts for twitter api credentials and returns a client
  # ---
  def initialize_twitter_api_client
    puts 'Enter your Twitter API credentials (get some @ dev.twitter.com).'

    Twitter::REST::Client.new do |config|
      print 'consumer key: '
      config.consumer_key        = gets.chomp
      print 'consumer secret: '
      config.consumer_secret     = gets.chomp
      print 'oauth token: '
      config.oauth_token         = gets.chomp
      print 'oauth token secret: '
      config.oauth_token_secret  = gets.chomp
    end
  end

  # ---
  # returns array of non-retweet tweets, each as a hash containing
  # the tweet's with :time of creation and :text
  # ---
  def posts(twitter_username, count)
    options = { count: count, exclude_replies: true }
    twitter_client.user_timeline(twitter_username, options)
           .delete_if{ |t| t.retweeted || (t.text =~ /^RT\s@/) } # remove retweets
           .map { |tweet| { time: tweet.created_at, text: tweet.text } }
  end

  # ---
  # Fetches users and their tweets, iteratively saves them to file as YAML
  # ---
  def fetch_users_and_their_tweets
    users = avail_users.sample( number_of_users )

    puts ""
    users.each_with_index do |username, user_num|
      if user_exists_and_tweets_are_public?(username)
        fake_friends[username] = create_user_hash_for(username)
        update_output_file_with(username, user_num)
      end
    end

    puts "Finished fetching users and tweets"
  end

  private

  # ---
  # helper method
  # ---
  def user_exists_and_tweets_are_public?(u)
    twitter_client.user?(u) && !twitter_client.user(u).protected?
  end

  # ---
  # For a given Twitter user, returns a hash with the following strings:
  # name, location, description, url[:expanded], url[:display], image url
  # and an array containing the desired number of tweets
  # ---
  def create_user_hash_for(u)
    user  = twitter_client.user(u)       # load user
    posts = posts(u, max_posts_per_user) # fetch 100 posts

    begin     # get expanded url if it exists
      expanded_url = user.attrs[:entities][:url][:urls].first[:expanded_url]
    rescue
      expanded_url = nil
    end

    begin     # get display url if it exists
      display_url = user.attrs[:entities][:url][:urls].first[:display_url]
    rescue
      display_url = nil
    end

    {
      name: user.name, location: user.location,
      description: user.description,
      url: { expanded: expanded_url, display: display_url },
      image: user.profile_image_url, posts: posts
    }
  end

  # ---
  # Updates the ouput file with YAML for the array of
  # users in its current state
  # ---
  def update_output_file_with(user, number)
    File.open(output_file_rel_path, 'w') do |f|
      f.write(fake_friends.to_yaml)
    end

    puts "fetched and saved user #{number+1}: #{user}"

    if number_of_users <= 75
      # small number fetched in batches, rest every 15th user
      countdown_minutes(15) if (number+1 % 15 == 0)
    else
      # large number fetched at slow, steady pace
      countdown_minutes(1)
    end
  end

  # ---
  # Displays a countdown timer on the command line
  # for the given number of minutes
  # ---
  def countdown_minutes(min)
    puts "taking a #{min}-minute power nap to stay within Twitter API rate limits..."
    seconds = (min * 60).to_i

    (1..seconds).reverse_each do |sec|
      print "\r%02d:%02d:%02d" % [ sec / 3600, sec / 60, sec % 60 ]
      $stdout.flush
      sleep 1
    end
    puts
  end
end

twitter_api = TweetFetcher.new
twitter_api.fetch_users_and_their_tweets
