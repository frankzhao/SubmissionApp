class RemoveGetMarksFromPeerReviewCycle < ActiveRecord::Migration
  def change
    remove_column :peer_review_cycles, :get_marks
  end
end
