class RemoveMaximumMark < ActiveRecord::Migration
  def change
    remove_column :assignments, :maximum_mark
  end
end
