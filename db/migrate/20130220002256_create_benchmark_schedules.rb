class CreateBenchmarkSchedules < ActiveRecord::Migration
  def change
    create_table :benchmark_schedules do |t|
      t.integer :user_id
      t.integer :iterations

      t.timestamps
    end
  end
end
