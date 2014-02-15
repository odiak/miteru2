#!/usr/bin/env ruby
# coding: utf-8

require "bundler"
Bundler.require
require "./settings"

configure do
  set :app_file, __FILE__
  set :server, :webrick
  set :haml, format: :html5

  disable :sessions
  use Rack::Session::Cookie,
    key: "rack.session",
    expire_after: SESSION_EXPIRE_AFTER,
    secret: SESSION_SECRET

  use Rack::Csrf, raise: true

  use OmniAuth::Builder do
    provider :twitter, CONSUMER_KEY, CONSUMER_SECRET
  end
end

helpers do
  def current_user
    !session[:uid].nil?
  end

  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end

  def authorize!
    unless current_user
      session[:callback] = request.fullpath
      redirect to "/auth/twitter"
    end
  end
end

get "/auth/twitter/callback" do
  # p env["omniauth.auth"]["credentials"]["token"]
  # p env["omniauth.auth"]["credentials"]["secret"]
  session[:uid] = env["omniauth.auth"]["uid"]
  session[:oauth_token] = env["omniauth.auth"]["credentials"]["token"]
  session[:oauth_secret] = env["omniauth.auth"]["credentials"]["secret"]
  redirect to session[:callback] or "/"
end

get "/auth/failure" do
  "auth failure"
end

get "/" do
  haml :index
end

get "/post" do
  authorize!
  @title = params[:title]
  @url = params[:url]
  haml :post
end

post "/post" do
  client = Twitter::REST::Client.new do |config|
    config.consumer_key = CONSUMER_KEY
    config.consumer_secret = CONSUMER_SECRET
    config.access_token = session[:oauth_token]
    config.access_token_secret = session[:oauth_secret]
  end

  title = params[:title] || ""
  url = params[:url] || ""
  comment = params[:comment] || ""
  status = ""
  status << comment << "-" unless comment.empty?
  status << title << " " unless title.empty?
  status << url
  begin
    client.update(status)
  rescue Twitter::Error::ClientError
    redirect to "/failure"
  else
    redirect to "/success"
  end
end

get "/success" do
  haml :success
end

get "/failure" do
  haml :failure
end
