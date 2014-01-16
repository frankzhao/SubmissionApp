class CreateMarkingCategories < ActiveRecord::Migration
  def change
    create_table :marking_categories do |t|
      t.integer :assignment_id, :null => false
      t.string :name, :null => false
      t.string :source, :null => false
      t.string :description, :null => false
      t.integer :maximum_mark, :null => false

      t.timestamps
    end
  end
end
