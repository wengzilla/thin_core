class RoomsAddStatusColumn < ActiveRecord::Migration
  def change
    add_column :rooms, :status, :string, :default => "Pending"
  end
end
