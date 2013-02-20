class AddBenchmarkScheduleIdToDynamicProfiles < ActiveRecord::Migration
  def change
    add_column :dynamic_profiles, :benchmark_schedule_id, :integer
  end
end
