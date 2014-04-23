class CreateCustomBehaviorTable < ActiveRecord::Migration
  def change
    create_table :custom_behaviors do |t|
      t.integer :assignment_id, :null => false
      t.string :name, :null => false
      t.string :details

      t.timestamps
    end
  end
end
