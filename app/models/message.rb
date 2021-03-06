class Message < ActiveRecord::Base
  MESSAGE_ATTRS = [ :body, :room_id, :user_id, :user_type, :user_name, :message_type, :metadata ]
  attr_accessible *MESSAGE_ATTRS
  validates_length_of :body, :maximum => 1000
  validates_presence_of :room_id, :body
  store :metadata
  belongs_to :room

  def to_hash
    hash = { room_id: room_id,
             user_name: user_name,
             user_id: user_id,
             user_type: user_type,
             message_id: id,
             message_type: message_type,
             message_body: body,
             metadata: metadata,
             created_at: created_at,
             pretty_time: pretty_time }
  end

  def pretty_time
    if created_at
      created_at.strftime("%l:%M %p")
    else
      Time.now.strftime("%l:%M %p")
    end
  end

  def self.build_params_hash(params)
    params = JSON.parse(params) if params.class == String
    hash = {}
    MESSAGE_ATTRS.each do |attribute|
      hash[attribute] = params[attribute.to_s] if params.has_key? attribute.to_s
    end
    add_room_id_from_location(hash, params)
    merge_with_metadata(hash, params)
  end

  def self.add_room_id_from_location(hash, params)
    if params.has_key? "location"
      room = Room.find_by_name(params["location"])
      hash.tap do |h|
        hash[:room_id] = room ? room.id : 0
      end
    end
    #faye_server sends location, for Lobby. thin_file sends as room_id, for message.
  end

  def self.merge_with_metadata(hash, params)
    hash[:metadata] ||= {}
    hash.tap do |h|
      h[:metadata].merge!({client_id: params["client_id"], location: params["location"]})
    end
  end

  def in_room?
    # raise room_id.inspect
    room_id != 0
  end

  ["guest", "agent"].each do |type|
    define_method "from_#{type}?".to_sym do
      user_type == type.capitalize
    end
  end

  def subscribe?
    message_type == "Subscribe"
  end

  def disconnect?
    message_type == "Disconnect"
  end

  def room_channel
    room = Room.where(id: room_id).first
    room.present? ? "/messages/#{room.name}" : nil
  end

  def online_user_channel
    user_type ? "/online/#{user_type.downcase}" : "/online"
  end

  def get_channels
    if subscribe? || disconnect?
      [ online_user_channel, room_channel ].delete_if{ |x| x.nil? }
    else
      [ room_channel ]
    end
  end

  def broadcast
    publish_to_faye && publish_to_redis
  end

  def publish_to_faye
    messenger = Messenger.new("#{FAYE_URL}/faye")
    messenger.publish(get_channels, to_hash)
  end

  def publish_to_redis
    messenger = RedisMessenger.new
    messenger.publish(to_hash)
  end
end
