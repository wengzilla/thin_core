require 'eventmachine'

class RoomsController < ApplicationController;
  def index
    @rooms = Room.all
  end

  def create
    last_room = Room.order("id DESC").first
    number = last_room ? last_room.id + 1 : 1
    Room.create(name: "Room #{number}")
    redirect_to rooms_path
  end

  def show
    @room = Room.where(id: params[:id]).first
    @messages = @room.messages

    EM.run {
      client = Faye::Client.new('http://localhost:9292/faye')

      client.subscribe('/messages/3') do |message|
        puts message.inspect
      end

      client.publish('/messages/3', 'data' => 'alert()')
    }
  end
end
