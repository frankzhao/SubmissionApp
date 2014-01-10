class RemoveCommentUserIdRequirement < ActiveRecord::Migration
  def change
    change_column :comments, :user_id, :integer, :null => true
  end
end
