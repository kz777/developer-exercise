require 'rubygems'
gem 'google-api-client', '>0.7'
require 'google/api_client'

# Set DEVELOPER_KEY to the API key value from the APIs & auth > Credentials
# tab of
# Google Developers Console <https://console.developers.google.com/>
# Please ensure that you have enabled the YouTube Data API for your project.
DEVELOPER_KEY = 'REPLACE_ME'
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'

def get_service
  client = Google::APIClient.new(
    :key => DEVELOPER_KEY,
    :authorization => nil,
    :application_name => $PROGRAM_NAME,
    :application_version => '1.0.0'
  )
  youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

  return client, youtube
end

def main
  puts 'Enter your search here: '
  search_string = gets.chomp!

  client, youtube = get_service

  begin
    # Calling the search.list method to retrieve results matching the specified
    # query term.
    search_response = client.execute!(
      :api_method => youtube.search.list,
      :parameters => {
        :part => 'snippet',
        :q => search_string,
        :maxResults => 3
      }
    )

    videos = []

    # Add each result to the appropriate list, and then display the lists of
    # matching videos.
    search_response.data.items.each do |search_result|
      case search_result.id.kind
        when 'youtube#video'
          videos << "#{search_result.snippet.title} (https://www.youtube.com/watch?v=#{search_result.id.videoId})"
      end
    end

    puts "Videos:\n", videos, "\n"
  rescue Google::APIClient::TransmissionError => e
    puts e.result.body
  end
end

main