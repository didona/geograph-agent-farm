class CreateAgentGroups < ActiveRecord::Migration
  def change
    create_table :agent_groups do |t|
      t.string :simulator
      t.integer :sleep
      t.integer :threads
      t.integer :static_profile_id

      t.timestamps
    end
  end
end
