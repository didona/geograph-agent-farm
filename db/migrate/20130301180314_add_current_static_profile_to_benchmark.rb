class AddCurrentStaticProfileToBenchmark < ActiveRecord::Migration
  def change
  	add_column :benchmark_schedules, :static_profile_id, :integer
  	add_column :benchmark_schedules, :static_profile_progress, :integer
  end
end
