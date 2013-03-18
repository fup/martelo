require 'rubygems'
require 'bundler/setup'
require File.join(File.dirname(__FILE__), "/lib/", 'martelo.rb')

run Martelo::App
