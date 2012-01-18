class AddGeoObjectToAgent < ActiveRecord::Migration
  def change
    add_column(:agents, :geo_object, :integer)
  end
end
