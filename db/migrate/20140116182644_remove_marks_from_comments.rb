class RemoveMarksFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :marks
  end
end
