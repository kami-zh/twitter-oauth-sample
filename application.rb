require './config.rb'

require 'sinatra'
require 'sinatra/reloader'
require 'oauth'
require 'json'
require 'better_errors'
require 'binding_of_caller'

use Rack::Session::Pool
use BetterErrors::Middleware

def sign_in
  session[:access_token] = session[:request_token].get_access_token(oauth_verifier: params[:oauth_verifier])
  session[:signed_in] = true
  session.delete(:request_token)
end

def sign_out
  session.clear
end

def signed_in?
  session[:signed_in]
end

def sign_in_url
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

def user
  { user_id: user_id, screen_name: screen_name, name: name }
end

def user_id
  session[:access_token].params[:user_id]
end

def screen_name
  session[:access_token].params[:screen_name]
end

def name
  response = session[:access_token].request(:get, "https://api.twitter.com/1.1/users/show.json?user_id=#{user_id}")
  result = JSON.parse(response.body)
  result['name']
end

get '/' do
  if signed_in?
    @user = user
    erb :signed_in
  else
    erb :not_signed_in
  end
end

get '/signin' do
  redirect sign_in_url
end

get '/signout' do
  sign_out
  redirect '/'
end

get '/sessions/create' do
  sign_in
  redirect '/'
end
