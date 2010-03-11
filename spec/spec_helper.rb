ENV['RACK_ENV'] = 'test'
require 'rubygems'

require File.expand_path('../lib/sinatra-twitter-oauth', File.dirname(__FILE__))

require 'spec'
require 'spec/interop/test'
require 'rack/test'

Test::Unit::TestCase.send :include, Rack::Test::Methods
