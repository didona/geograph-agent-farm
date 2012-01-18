class AddStatusToAgentGroups < ActiveRecord::Migration
  def change
    add_column :agent_groups, :status, :string, :default => 'idle'
  end
end
