class AddPositionToProfile < ActiveRecord::Migration
  def change
  	add_column :dynamic_profiles, :position, :integer
  end
end
