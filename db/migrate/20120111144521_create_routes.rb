class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :name      
    end

    create_table :positions do |t|
      t.float :latitude, :longitude
      t.integer :route_id, :progressive
    end
  end

end
