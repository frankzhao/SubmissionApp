class AddIsFinalizedToSubmissions < ActiveRecord::Migration
  def change
    add_column :assignment_submissions, :is_finalized, :boolean, :default => false
  end
end
