#!/usr/bin/env ruby -I ../lib -I lib
require 'sinatra'
require "sinatra/content_for"
require 'haml'
require 'omniauth'
require 'omniauth-salesforce'
require 'rack/ssl'

  use Rack::SSL
  use Rack::Session::Cookie, :secret => '...'


  #set :public_folder, File.dirname(__FILE__) + '/assets'

  use OmniAuth::Builder do
    provider :salesforce, '3MVG9rFJvQRVOvk4936qVmFb9yxAJCElOj_ZTEvvw9.AtpgUE0ua6_1ky3LgU0jEJUaNs5gXpGP44mrTeTKBb', '3518815754735670695'
  end

  get '/' do
    haml :intro
  end

