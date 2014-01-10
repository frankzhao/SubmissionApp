class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name, :null => false
      t.integer :convener_id, :null => false

      t.timestamps
    end
  end
end
