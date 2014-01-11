class ChangeSpelling < ActiveRecord::Migration
  def change
    rename_column :assignments, :behaviour_on_submission, :behavior_on_submission
  end
end
