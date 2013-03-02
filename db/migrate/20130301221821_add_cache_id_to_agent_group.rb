class AddCacheIdToAgentGroup < ActiveRecord::Migration
  def change
    add_column :agent_groups, :cache_id, :string
  end
end
