class AddIsVisibleToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :is_visible, :boolean, :default => true
  end
end
