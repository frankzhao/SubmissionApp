class AddSlugToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :slug, :string

    add_index :assignments, :slug, :unique => true
  end
end
