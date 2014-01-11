class AddDefaultsToBehaviorOnSubmission < ActiveRecord::Migration
  def change
    change_column :assignments, :behavior_on_submission, :string, :default => ""
  end
end
