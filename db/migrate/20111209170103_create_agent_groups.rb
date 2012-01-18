class CreateAgentGroups < ActiveRecord::Migration
  def change
    create_table :agent_groups do |t|
      t.string :name
      t.integer :delay
      t.timestamps
    end
  end

  add_column :agents, :agent_group_id, :integer
end
