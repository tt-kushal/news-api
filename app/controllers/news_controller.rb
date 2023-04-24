
require 'uri'
require 'net/http'

class NewsController < ApplicationController
  def index
    response = RestClient.get('https://newsapi.org/v2/top-headlines?country=us&apiKey=b4b93ad32dd1451eb1661ea4a316ca5f')
    @articles = JSON.parse(response.body)['articles']
  end

  def audio
    text = params[:text]
    voice = params[:voice] || 'en-US'
    speed = params[:speed] || '0'
    api_key = 'e2c643b1bdmsh883a81caf236e9ap1dc8f3jsn1d535a0d2254'

   
    encoded_text = URI.encode_www_form_component(text)

    url = URI("https://voicerss-text-to-speech.p.rapidapi.com/?key=#{api_key}&hl=#{voice}&src=#{encoded_text}&r=#{speed}&f=48khz_16bit_stereo")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['X-RapidAPI-Host'] = 'voicerss-text-to-speech.p.rapidapi.com'
    request['X-RapidAPI-Key'] = api_key

    response = http.request(request)

    if response.code == '200'
      audio_data = response.body
      send_data(
       audio_data,type: 'audio/mpeg',disposition: 'inline',filename: "audio-#{Time.now.to_i}.mp3"
)
    else
      render plain: "Error: #{response.message}", status: response.code
    end
    
  end
end




