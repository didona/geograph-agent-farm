class AddIterationsOnProfiles < ActiveRecord::Migration
  def change
  	add_column :dynamic_profiles, :iterations, :integer, :default => 1
  	add_column :dynamic_profiles, :current_iteration, :integer, :default => 1

		add_column :benchmark_schedules, :current_iteration, :integer, :default => 1
  end
end
