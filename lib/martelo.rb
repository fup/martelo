module Martelo
  require 'sinatra'
  require 'resolv'
  require 'erb'
  require 'haml'
  require 'rbvmomi'
  require 'redis'
  require 'json/pure'

  require File.join(File.dirname(__FILE__),'/martelo/server.rb')
  require File.join(File.dirname(__FILE__),'/martelo/app.rb')
  require File.join(File.dirname(__FILE__),'/martelo/vmware.rb')
  require File.join(File.dirname(__FILE__),'/martelo/cache.rb')
end
