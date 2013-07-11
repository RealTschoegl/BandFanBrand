require 'twitter'
require 'json'
require 'open-uri'
require 'pry'
require 'uri'

Twitter.configure do |config|
	config.consumer_key = "WGKsIyF1bIgyMzyOyfPlUw"
	config.consumer_secret = "opQAAE16rGBMhSN9RhHR2w3rbnLPku4G83kaKChyyI"
	config.oauth_token = "499825106-3OUNfxYMxxhXXlfVq4Nqx5aeSjwwhainYIbDkR5i"
	config.oauth_token_secret = "jlDv0dzbckoV1YT8LpqlvjAqozU6lFmXYKLOYDW8"
end

# Array for Handles 
tweeter_array_1 = []

# Array for Locations
@MasterBlaster = []

# Array for Markers
@markers = []

# Array for Newly Joined Markers
@new_markers = []

#User Input Dialogue
puts "What band or album do you want to look for?"
search_term_1 = gets.chomp!
if search_term_1[0] == "#"
  @search_term = search_term_1[1..-1]
else 
  @search_term = search_term_1
end
puts "Cool.  Wait a second for the results."

puts "What is the Twitter handle of the band?"
search_handle_1 = gets.chomp!
if search_handle_1[0] == "@"
  @search_handle = search_handle_1[1..-1]
else
  @search_handle = search_handle_1
end
puts "Cool.  Wait a second for the results."

# Use search to find handles
Twitter.search("#{@search_term}", :lang => "en", :count => 20).results.each do |tweet|
   tweeter_array_1.push(tweet.from_user) 
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
m = "http://maps.googleapis.com/maps/api/staticmap?center=Austin,TX&zoom=1&size=640x600&markers=size:mid%7Ccolor:red#{t}&maptype=satellite&sensor=false"

# This opens the google map in an html file to be viewed in browser
File.open("googlemaps.html", 'w') do |f|
  f.write("<head><link rel='stylesheet' href='style.css' type='text/css'><head>")
  f.write("<body><div class='wrapper'><h3>Here is a map of your tweeters and followers:</h3>") 
  f.write("<h3>Search Term: ##{@search_term}</h3>")
  f.write("<h3>Search Handle: @#{@search_handle}</h3>")
  f.write("<br />")
  f.write("<div id='container'>")
  f.write("<img src='#{m}' >")
  f.write("</div></div></body>")
end


