class AddCustomBehaviorIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :custom_behavior_id, :integer
  end
end
