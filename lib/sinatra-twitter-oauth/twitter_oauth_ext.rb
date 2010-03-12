
#
# Some additional domain model classes for twitter oauth.
#
module TwitterOAuth

  class User
    attr_accessor :client,:info
    
    def initialize client,info
      self.client = client
      self.info = info
    end
    
    #updates the user's status
    # msg -- message to update to
    # opts additional options eg lat,long
    
    def update_status msg, opts={}
      client.update msg, opts
    end
    
    def lists
      client.get_lists(screen_name)['lists'].map {|list| List.new client, list}
    end
    
    def list list_name
      List.new client, client.get_list(screen_name, list_name)
    end
    
    def new_list list_name,options={}
      List.new client, client.create_list(screen_name, list_name, options)
    end
    
    def destroy_list list_name
      client.delete_list screen_name, list_name
    end
    
    def method_missing method, *args
      info[method.to_s]
    end
  end
  
  
  class List
    
    attr_accessor :client,:info
    
    #params:
    #  client: instance of TwitterOAuth::Client
    #  info: the result of client.get_list
    def initialize client,info
      self.info = info
      self.client = client
    end
    
    def add_member screen_name
      client.add_member_to_list user['screen_name'],slug, client.show(screen_name)["id"]
    end
    
    def add_members screen_names
      screen_names.each {|name| add_member name }
    end
    
    def remove_member screen_name
      client.remove_member_from_list user['screen_name'],slug, client.show(screen_name)["id"]
    end
    
    def remove_members screen_names
      screen_names.each {|name| remove_member name }
    end

    def members
      client.list_members(user['screen_name'], slug)['users'].map{|user| User.new(client,user)}
    end
    
    def private?
      mode == 'private'
    end
    
    def method_missing method, *args
      info[method.to_s]
    end
    
  end
end
 
