class Agent < ActiveRecord::Base
  attr_accessible :name, :thin_auth_id
  has_many :room_agents
  has_many :rooms, :through => :room_agents

  def self.find_or_create_by_thin_auth_id(params)
    unless agent = Agent.where(thin_auth_id: params["id"]).first
      agent = Agent.create(thin_auth_id: params["id"], name: params["name"])
    end
    agent
  end
end