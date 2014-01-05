class AddZipStuff < ActiveRecord::Migration
  def change
    change_column :assignment_submissions, :body, :string, :null => true
    add_column :assignment_submissions, :zip_file, :blob

    add_column :assignments, :submission_format, :string, :null => false, :default => "plaintext"
  end
end
