class Api::V1::MessagesController < ApplicationController
  respond_to :json

  def index
    if room = Room.where(id: params[:room_id].to_s).first
      @messages = room.messages
    else
      render :json => {:error => "Room not found."}, :status => :not_found
    end
  end
end