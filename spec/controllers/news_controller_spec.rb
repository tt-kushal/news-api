require 'rails_helper'

RSpec.describe NewsController, type: :controller do
  describe "#index" do
    it "fetches the top headlines" do
      get :index
      expect(response.status).to eq 200
      expect(assigns(:articles)).not_to be_nil
    end
  end

  describe "#audio" do
  let(:api_key) { 'e2c643b1bdmsh883a81caf236e9ap1dc8f3jsn1d535a0d2254' }
  let(:voice) { 'en-US' }
  let(:speed) { '0' }
  
  before do
    # Fetch the top headlines from the News API
    response = RestClient.get('https://newsapi.org/v2/top-headlines?country=us&apiKey=b4b93ad32dd1451eb1661ea4a316ca5f')
    articles = JSON.parse(response.body)['articles']
    
    # Set the text parameter to the title of the first article
    @text = articles.first['title']
  end
  
  it "returns an audio file for the given text" do
    encoded_text = URI.encode_www_form_component(@text)
    
    url = URI("https://voicerss-text-to-speech.p.rapidapi.com/?key=#{api_key}&hl=#{voice}&src=#{encoded_text}&r=#{speed}&f=48khz_16bit_stereo")
    
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(url)
    request['X-RapidAPI-Host'] = 'voicerss-text-to-speech.p.rapidapi.com'
    request['X-RapidAPI-Key'] = api_key
    
    response = http.request(request)
    
    get :audio, params: { text: @text, voice: voice, speed: speed }
    
    expect(response.code).to eq '200'
    expect(response.content_type).to eq 'audio/mpeg'
    expect(response.headers['Content-Disposition']).to include('inline')
    expect(response.headers['Content-Disposition']).to include('filename= audio-#{Time.now.to_i}.mp3')
  end
end
end 
