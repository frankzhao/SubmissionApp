class RemoveCustomBehavior < ActiveRecord::Migration
  def change
    remove_column :assignments, :behavior_on_submission
  end
end
