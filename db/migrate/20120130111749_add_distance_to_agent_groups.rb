class AddDistanceToAgentGroups < ActiveRecord::Migration
  def change
    add_column(:agent_groups, :distance, :integer)
  end
end
