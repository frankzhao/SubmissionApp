class AddFilesAndParentsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :has_file, :boolean, :default => false
    add_column :comments, :parent_id, :integer
  end
end
