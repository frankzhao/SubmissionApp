class AddCommentsVisibleToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :visible_comments, :boolean, :default => true
  end
end
