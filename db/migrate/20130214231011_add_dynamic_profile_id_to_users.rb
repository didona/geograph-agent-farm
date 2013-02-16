class AddDynamicProfileIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_profile_id, :integer
  end
end
