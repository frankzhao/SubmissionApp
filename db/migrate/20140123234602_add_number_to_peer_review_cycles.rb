class AddNumberToPeerReviewCycles < ActiveRecord::Migration
  def change
    add_column :peer_review_cycles, :number_of_swaps, :integer
  end
end
