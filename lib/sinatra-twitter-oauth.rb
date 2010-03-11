require 'sinatra/base'
require 'twitter_oauth'

require 'sinatra-twitter-oauth/twitter_oauth_ext'
require 'sinatra-twitter-oauth/helpers'
#Sinatra::TwitterOAuth
#
# A sinatra extension that abstracts away most of
# using twitter oauth for login
#
#twitter_oauth_config
#options
# key -- oauth consumer key
# secret -- oauth consumer secret
# callback -- oauth callback url. Must be absolute. e.g. http://example.com/auth
# login_template -- a single entry hash with the engine as the key e.g. :login_template => {:haml => :login}
module Sinatra
  module TwitterOAuth
  
    DEFAULT_CONFIG = {
      :key      => 'changeme',
      :secret   => 'changeme',
      :callback => 'changeme',
      :login_template => {:text=>'<a href="/connect">Login using Twitter</a>'}
    }
  
    def self.registered app  # :nodoc:
    
      app.helpers Helpers
      app.enable :sessions
      app.set :twitter_oauth_config, DEFAULT_CONFIG
        
      app.get '/login' do
        redirect '/' if user
        
        login_template = options.twitter_oauth_config[:login_template]
        
        engine = login_template.keys.first
        
        case engine
        when :text
          login_template[:text]
        else
          render engine, login_template[engine]
        end
      end
      
      app.get '/connect' do
        redirect_to_twitter_auth_url
      end

      app.get '/auth' do
        if authenticate!
          redirect '/'
        else
          status 403
          'Not Authenticated'
        end
      end
      
      app.get '/logout' do
        clear_oauth_session
        redirect '/login'
      end
    end
    
  end
  
  register TwitterOAuth
end
