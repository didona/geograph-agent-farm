class AddStartdateToBenchmark < ActiveRecord::Migration
  def change
  	add_column :benchmark_schedules, :start_time, :datetime
  end
end
