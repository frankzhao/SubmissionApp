class CreateGroupTypes < ActiveRecord::Migration
  def change
    create_table :group_types do |t|
      t.string :name, :null => false

      t.timestamps
    end

    add_index :group_types, :name, :unique => true
  end
end
