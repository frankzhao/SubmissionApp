class AddCycleIdToSubmissionPermissions < ActiveRecord::Migration
  def change
    add_column :submission_permissions, :peer_review_cycle_id,
                                                :integer

  end
end
