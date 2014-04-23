class AddExplicitFilenameToComments < ActiveRecord::Migration
  def change
    add_column :comments, :explicit_filepath, :string
  end
end
