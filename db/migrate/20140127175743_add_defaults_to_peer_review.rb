class AddDefaultsToPeerReview < ActiveRecord::Migration
  def change
    change_column :peer_review_cycles, :anonymise, :boolean, { :null => false, :default => false}
    change_column :peer_review_cycles, :shut_off_submission, :boolean, { :null => false, :default => false}
  end
end
