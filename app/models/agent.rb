class Agent
  attr_accessor :name, :thin_auth_id, :email, :client_ids

  def id
    thin_auth_id
  end

  def initialize(thin_auth_id, email, name=nil)
    @thin_auth_id = thin_auth_id.to_i
    @email = email
    @name = name
  end

  def self.new_from_cookie(cookie)
    params = JSON.parse(cookie)
    Agent.new(params["id"], params["email"], params["name"])
  end

  def channel
    "/agents/#{id}"
  end

  def user_hash(location = nil)
    hash = { user_id: id.to_s, user_type: 'Agent', user_name: name, private_channel: channel}
    location ? hash[:room_id] = location : hash
  end

  def self.find_by_authentication_token(token)
    uri = URI.parse("#{root_url}auth/api/v1/users.json?authentication_token=#{token}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)["authentication_token"]
  end

  ["guest", "agent"].each do |user_type|
    define_method "#{user_type}?".to_sym do
      self.class.to_s.downcase == user_type
    end
  end
end
