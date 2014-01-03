class FixComments < ActiveRecord::Migration
  def up
    rename_column :comments, :assignment_id, :assignment_submission_id
  end
end
