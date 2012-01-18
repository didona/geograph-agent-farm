class StiForAgents < ActiveRecord::Migration
  def change
    add_column(:agents, :type, :string)
    add_column(:agent_groups, :agents_type, :string)
  end
end
