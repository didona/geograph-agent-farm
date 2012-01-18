class AddLastActionToAgent < ActiveRecord::Migration
  def change
    add_column(:agents, :last_action, :text)
  end
end
