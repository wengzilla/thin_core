class Room < ActiveRecord::Base
  attr_accessible :name, :status, :guest_id
  attr_accessor :users
  has_many :messages
  before_create :set_name
  belongs_to :guest

  def self.in_queue
    statuses = [ "Pending", "Active" ]
    Room.where{status.in statuses}
  end

  def set_name
    self.name = rand(36**8).to_s(16)
  end

  ["pending", "active", "closed"].each do |room_status|
    define_method "#{room_status}?".to_sym do
      status == room_status.capitalize
    end
  end

  def open?
    !closed?
  end

  def channel
    "/messages/#{name}"
  end

  def change_to_active
    self.update_attribute(:status, "Active") if status == "Pending"
  end
end