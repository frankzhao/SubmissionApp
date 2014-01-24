class AddTimesToSubmissionPermissions < ActiveRecord::Migration
  def change
    add_column(:submission_permissions, :created_at, :datetime)
    add_column(:submission_permissions, :updated_at, :datetime)
  end
end
