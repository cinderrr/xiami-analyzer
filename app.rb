require 'sinatra'
require 'cgi'
require 'net/http'
require 'json'

def decode location
  string    = location[1..-1]
  col       = location[0].to_i
  row       = (string.length.to_f / col).floor
  remainder = string.length % col
  address   = [[nil]*col]*(row+1)
  sizes = [row+1] * remainder + [row] * (col - remainder)
  pos = 0
  sizes.each_with_index { |size, i|
    size.times { |index| address[col * index + i] = string[pos + index] }
    pos += size
  }
  address = CGI::unescape(address.join).gsub('^', '0')
end

def retrieve_songs url
  json = JSON.parse Net::HTTP.get URI.parse url
  tracks = json['data']['trackList']
  songs = tracks.map do |t|
    {
      title: t['title'],
      artist: t['artist'],
      album: t["album_name"],
      cover: t["pic"].gsub('_1.jpg','_2.jpg'),
      mp3: decode(t["location"])
    }
  end
  songs.to_json
end

before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*'
end

get '/' do
  content_type :html
  'GET /song/:id<br>GET /collection/:id'
end

get '/song/:id' do
  retrieve_songs "http://www.xiami.com/song/playlist/id/#{params[:id]}/type/0/cat/json"
end

get '/collection/:id' do
  retrieve_songs "http://www.xiami.com/song/playlist/id/#{params[:id]}/type/3/cat/json"
end