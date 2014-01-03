class AddSubmissionRules < ActiveRecord::Migration
  def change
    add_column :assignments, :submission_policy, :string
  end
end
