class AddFilenameToComments < ActiveRecord::Migration
  def change
    add_column :comments, :file_name, :string
  end
end
