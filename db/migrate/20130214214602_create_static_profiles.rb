class CreateStaticProfiles < ActiveRecord::Migration
  def change
    create_table :static_profiles do |t|
      t.integer :duration
      t.integer :dynamic_profile_id
      t.integer :position

      t.timestamps
    end
  end
end
