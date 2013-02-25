class AddActiveToBenchmarkSchedule < ActiveRecord::Migration
  def change
    add_column :benchmark_schedules, :active, :boolean, :default => false
  end
end
