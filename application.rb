require './config.rb'

require 'oauth'
require 'json'
require 'sinatra'
require 'sinatra/reloader'
require 'better_errors'
require 'binding_of_caller'

use Rack::Session::Pool
use BetterErrors::Middleware

def signed_in?
  session[:signed_in]
end

def signin_url
  consumer = OAuth::Consumer.new(
    API_KEY,
    API_SECRET,
    site: 'https://api.twitter.com'
  )
  request_token = consumer.get_request_token(
    oauth_callback: OAUTH_CALLBACK
  )
  session[:request_token] = request_token
  request_token.authorize_url
end

def user_id
  session[:access_token].params[:user_id]
end

def screen_name
  session[:access_token].params[:screen_name]
end

# とりあえずnameだけ取得してみる
def name
  response = session[:access_token].request(:get, "https://api.twitter.com/1.1/users/show.json?user_id=#{user_id}")
  result = JSON.parse(response.body)
  result['name']
end

# とりあえずコンソールで確認
get '/' do
  if signed_in?
    p 'signed in'
    p user_id
    p screen_name
    p name
    p "<a href=\"/signout\">Sign out</a>"
  else
    p "<a href=\"/signin\">Sign in</a>"
  end
end

get '/signin' do
  redirect signin_url
end

get '/signout' do
  session.clear
  redirect '/'
end

get '/callback' do
  session[:access_token] = session[:request_token].get_access_token(oauth_verifier: params[:oauth_verifier])
  session[:signed_in] = true
  session.delete(:request_token)
  redirect '/'
end
