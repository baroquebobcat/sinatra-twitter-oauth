require 'spec_helper'

class TestApp < Sinatra::Base
  register Sinatra::TwitterOAuth
  
  get '/' do
    login_required
    'hello world'
  end
end

describe Sinatra::TwitterOAuth do

  def app
    TestApp
  end
  
  before do 
    @client=mock('client',
        :rate_limit_status=>{
          "remaining_hits"=>150,
          "hourly_limit"=>150,
          "reset_time_in_seconds"=>0,
          "reset_time"=>"Sat Jan 01 00:00:00 UTC 2000"
        })
    TwitterOAuth::Client.stub!(:new).and_return(
      @client=mock('client',
      :rate_limit_status=>{"remaining_hits"=>150,"hourly_limit"=>150,"reset_time_in_seconds"=>0,"reset_time"=>"Sat Jan 01 00:00:00 UTC 2000"}))
    
    TwitterOAuth::User.stub!(:new).and_return(@user = mock('user'))
    
    @authed_session = {'rack.session'=>{:user => {'screen_name'=>'tester'}}}
  end
  
  describe 'protected by login_required' do
    it 'redirects to /login when unauthenticated' do
      get '/'
      last_response.should be_redirect
      last_response.location.should == '/login'
    end
    
    it 'lets you through if you are authed' do
      @user.stub!(:lists).and_return [mock('list',:null_object=>true)]
      get '/',{},@authed_session
      last_response.location.should be_nil
      last_response.should be_ok
    end
  end
  
  describe 'GET /login' do
    it 'is never redirected' do
      get '/login'
      last_response.location.should be_nil
      last_response.should be_ok
    end
  end
  
  
  describe 'GET /connect' do
    it 'gets a request token' do
      @client.should_receive(:authentication_request_token).and_return(mock('request token',:authorize_url=>'http://example.com',:token=>'token',:secret=>'secret'))
      get '/connect'
    end
    it "redirects to the request token's auth url" do
      @client.stub!(:authentication_request_token).and_return(token = mock('request token',:token=>'token',:secret=>'secret'))
      token.should_receive(:authorize_url).and_return 'http://example.com'
      get '/connect'
      last_response.location.should == 'http://example.com'
    end
  end
  
  describe 'GET /auth' do
    describe "on auth denied" do
      it "responds with 'Not Authenticated' and a 403" do
        @client.stub!(:authorize).and_raise OAuth::Unauthorized.new
        @client.stub!(:authorized?).and_return false
        get '/auth'
        last_response.status.should == 403
        last_response.body.should == 'Not Authenticated'
      end
    end
    describe 'on auth success' do
      it "redirects to '/'" do
        @client.stub!(:authorize).and_return(mock('access token',:null_object => true))
        @client.stub!(:authorized?).and_return true
        @client.stub!(:info).and_return(mock(:user))
        get '/auth'
        last_response.location.should == '/'
      end
    end
  end
  
  describe "GET /logout" do
    it "redirects to /login" do
      get '/logout',{},@authed_session
      last_response.location.should == '/login'
    end
  end
end
