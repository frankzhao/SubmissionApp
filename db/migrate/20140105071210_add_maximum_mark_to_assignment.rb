class AddMaximumMarkToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :maximum_mark, :integer, :null => false, :default => 100
  end
end
