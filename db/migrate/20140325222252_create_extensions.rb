class CreateExtensions < ActiveRecord::Migration
  def change
    create_table :extensions do |t|
      t.integer :user_id, :null => false
      t.integer :assignment_id, :null => false
      t.datetime :due_date, :null => false

      t.timestamps
    end
  end
end
