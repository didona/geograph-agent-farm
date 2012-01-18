class AddPositionToAgent < ActiveRecord::Migration
  def change
    add_column(:agents, :latitude, :float)
    add_column(:agents, :longitude, :float)
  end
end
