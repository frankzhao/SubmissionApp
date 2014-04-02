class AddBlobToFiles < ActiveRecord::Migration
  def change
    add_column :submission_files, :file_blob, :blob
  end
end
