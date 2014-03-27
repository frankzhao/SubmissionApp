class CreateSubmissionFiles < ActiveRecord::Migration
  def change
    create_table :submission_files do |t|
      t.integer :assignment_submission_id
      t.string :name
      t.string :body

      t.timestamps
    end
  end
end
