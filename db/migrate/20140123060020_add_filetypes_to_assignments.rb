class AddFiletypesToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :filetypes_to_show, :string
  end
end
