class AddSubmissionInstructionsToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :submission_instructions, :string
  end
end
