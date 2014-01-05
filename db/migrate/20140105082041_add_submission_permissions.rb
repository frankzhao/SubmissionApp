class AddSubmissionPermissions < ActiveRecord::Migration
  def change
    create_table :submission_permissions do |t|
      t.integer :assignment_submission, :null => false
      t.integer :user_id, :null => false
    end

  end
end
