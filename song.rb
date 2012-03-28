#!/usr/bin/env ruby -I ../lib -I lib
require 'sinatra'
require "sinatra/content_for"
require 'haml'
require 'databasedotcom'
require 'yaml'
require 'omniauth'
require 'omniauth-salesforce'
require 'resque'

  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  config = YAML.load_file("config/salesforce.yml") rescue {}
  client_id = config["client_id"]
  client_secret = config["client_secret"]

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :salesforce, config["client_id"], config["client_secret"]
  end

  module Updatelead
    @queue = :lead
    config = YAML.load_file("config/salesforce.yml") rescue {}
    @client_id = config["client_id"]
    @client_secret = config["client_secret"]
    @username = config["username"]
    @password = config["password"]

    def self.perform(leadsource)
      puts "update all Leads"
      dbdc = Databasedotcom::Client.new(:client_id => @client_id, :client_secret => @client_secret)
      dbdc.authenticate :username => @username, :password => @password 
      dbdc.materialize('Lead')
      leads = Lead.all
      leads.each{ |lead| lead.update_attribute('LeadSource',leadsource) }
      puts "updated all Leads"
    end
  end

  get '/' do
    haml :intro
  end

  get '/auth/salesforce/callback' do
    @token = request.env['omniauth.auth']
    haml :home
  end

  get '/home' do
    haml :home
  end

  post '/workers/updatelead' do
    Resque.enqueue(Updatelead,params["leadsource"])
    redirect 'home'
  end

  get "/logout" do
    redirect "/"
  end
 
