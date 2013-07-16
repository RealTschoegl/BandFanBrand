require 'sinatra'
require 'bundler/setup'
require 'twitter'
require 'json'
require 'open-uri'
require 'pry'
require 'uri'
require 'shotgun'

get '/' do
  erb :index
end

get '/map/' do

  Twitter.configure do |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
    config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
  end

    puts ENV['TWITTER_CONSUMER_KEY']
    puts ENV['TWITTER_CONSUMER_SECRET']
    puts ENV['TWITTER_OAUTH_TOKEN']
    puts ENV['TWITTER_OAUTH_TOKEN_SECRET']

  # Array for Handles 
  tweeter_array_1 = []

  # Array for Locations
  @MasterBlaster = []

  # Array for Markers
  @markers = []

  # Array for Newly Joined Markers
  @new_markers = []

  #User Input Dialogue
  search_term_1 = params[:searchTerm] 
  if search_term_1[0] == "#"
    @search_term = search_term_1[1..-1]
  else 
    @search_term = search_term_1
  end

  search_handle_1 = params[:searchHandle]
  if search_handle_1[0] == "@"
    @search_handle = search_handle_1[1..-1]
  else
    @search_handle = search_handle_1
  end

  # Use search to find handles
  Twitter.search("#{@search_term}", :lang => "en", :count => 20).results.each do |tweet|
     tweeter_array_1.push(tweet.from_user) 
  end

  # Find Twitter followers of an artist
  Twitter.followers("#{@search_handle}").each do |guy|
    location_entry = google_locater(guy.location)
    @MasterBlaster << {:user_name => guy.screen_name, :location => location_entry}
  end

  # Find location based on handle
  tweeter_array_1.each do |handle|
    location_entry = google_locater("#{Twitter.user(handle).location}")
    @MasterBlaster << { :user_name => handle, :location => location_entry } if location_entry
  end


  #Add the %7 Separator to each Marker entry
  @markers.each do |mark|
    this_marker = "|#{mark}"
    @new_markers << this_marker
  end

  #Joining the markers 
  t = @new_markers.join('')

  # The combined new URL
  @m = "http://maps.googleapis.com/maps/api/staticmap?center=Austin,TX&zoom=1&size=640x600&markers=size:mid%7Ccolor:red#{t}&maptype=satellite&sensor=false"  
  
  erb :map 

end

# Google Locator 
def google_locater(location)
    address_from_user = "#{location}"
    @usable_address = ""
    if address_from_user != ""
      @usable_address = address_from_user
    else
      @usable_address = "none"
    end
    uri_clean = URI.escape("https://maps.googleapis.com/maps/api/geocode/json?address=#{@usable_address}&sensor=false")
    response = open(uri_clean).read
    parsed_response = JSON.parse(response)
    if parsed_response["results"].empty?
      return nil
    else
      final_address = "#{(parsed_response["results"][0]["geometry"]["location"]["lat"]).round(2)},#{(parsed_response["results"][0]["geometry"]["location"]["lng"]).round(2)}"
      @markers.push(final_address)
      return final_address
    end
end

