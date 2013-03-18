require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), "../lib/", 'martelo.rb')

require 'rack/test'
require 'rspec'
require 'rest-client'

# test environment set
ENV['RACK_ENV'] = 'test'
set :run, false
set :raise_errors, true
set :logging, true
