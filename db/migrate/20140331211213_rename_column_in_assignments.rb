class RenameColumnInAssignments < ActiveRecord::Migration
  def change
    rename_column :assignments, :filetypes_to_show, :filepath_regex
  end
end
