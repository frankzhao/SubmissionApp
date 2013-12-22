class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :name, :null => false
      t.text :info, :null => false

      t.timestamps
    end
  end
end
