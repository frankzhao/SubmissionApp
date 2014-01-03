class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :assignment_id, :null => false
      t.integer :user_id, :null => false
      t.integer :mark
      t.string :body

      t.timestamps
    end
  end
end
