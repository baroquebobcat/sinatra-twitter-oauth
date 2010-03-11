module Sinatra::TwitterOAuth
  #Helpers exposed by the extension.
  #
  module Helpers
    
    # The current logged in user
    def user
      @user
    end
    
    # Redirects to login unless there is an authenticated user
    def login_required
      setup_client
      
      @user = ::TwitterOAuth::User.new(@client, session[:user]) if session[:user]
      
      @rate_limit_status = @client.rate_limit_status
      
      redirect '/login' unless user
    end
    
    
    def setup_client # :nodoc:
      @client ||= ::TwitterOAuth::Client.new(
        :consumer_secret => options.twitter_oauth_config[:secret],
        :consumer_key => options.twitter_oauth_config[:key],
        :token  => session[:access_token],
        :secret => session[:secret_token]
      )
    end 
    
    def get_request_token # :nodoc:
      setup_client
      
      begin
        @client.authentication_request_token(:oauth_callback=>options.twitter_oauth_config[:callback])
      rescue StandardError => e
        halt 500,'check your key & secret'
      end
    end
    
    def get_access_token # :nodoc:
      setup_client
      
      begin
        @client.authorize(
            session[:request_token],
            session[:request_token_secret],
            :oauth_verifier => params[:oauth_verifier]
         )
      rescue OAuth::Unauthorized => e
        nil
      end
    end
    
    # gets the request token and redirects to twitter's OAuth endpoint
    def redirect_to_twitter_auth_url
      request_token = get_request_token
    
      session[:request_token] = request_token.token
      session[:request_token_secret]= request_token.secret
    
      redirect request_token.authorize_url.gsub('authorize','authenticate')
    end
    
    # attempts to get the access token(MUST be used after user has been redirected back from twitter)
    def authenticate!
      access_token = get_access_token
    
      if @client.authorized?
        session[:access_token] = access_token.token
        session[:secret_token] = access_token.secret
        session[:user] = @client.info

        session[:user]
      else
        nil
      end
    end
    
    #removes all the session data defined by the extension
    def clear_oauth_session
      session[:user] = nil
      session[:request_token] = nil
      session[:request_token_secret] = nil
      session[:access_token] = nil
      session[:secret_token] = nil
    end
  end
end
