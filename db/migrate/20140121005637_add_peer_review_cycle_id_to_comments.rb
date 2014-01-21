class AddPeerReviewCycleIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :peer_review_cycle_id, :integer
  end
end
