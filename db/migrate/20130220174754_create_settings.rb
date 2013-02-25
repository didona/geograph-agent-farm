class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :stats_url
      t.string :map_url
      t.integer :user_id

      t.timestamps
    end
  end
end
