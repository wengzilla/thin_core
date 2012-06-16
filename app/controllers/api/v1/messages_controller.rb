class Api::V1::MessagesController < ApplicationController
  respond_to :json

  def index
    if room = Room.where(name: params[:room_name].to_s).first
      @messages = room.messages
    else
      render :json => {:error => "Room not found."}, :status => :not_found
    end
  end

  def create
    params_hash = Message.build_params_hash(params["message"])
    message = Message.new(params_hash)
    message.save if message.in_room?
    render :json => true, :status => 201 if message.broadcast
  end

end