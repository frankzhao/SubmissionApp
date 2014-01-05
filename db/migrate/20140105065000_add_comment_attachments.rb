class AddCommentAttachments < ActiveRecord::Migration
  def change
    add_column :comments, :parent_id, :integer, :null => false
    add_column :comments, :attachment, :boolean, :default => false
  end
end
