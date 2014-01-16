class CreateMarks < ActiveRecord::Migration
  def change
    create_table :marks do |t|
      t.integer :marking_category_id, :null => false
      t.integer :value, :null => false
      t.integer :comment_id, :null => false

      t.timestamps
    end
  end
end
