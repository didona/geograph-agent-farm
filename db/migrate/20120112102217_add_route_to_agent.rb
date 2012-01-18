class AddRouteToAgent < ActiveRecord::Migration
  def change
    add_column(:agents, :position_id, :integer)
  end
end
