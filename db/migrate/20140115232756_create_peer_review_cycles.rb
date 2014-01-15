class CreatePeerReviewCycles < ActiveRecord::Migration
  def change
    create_table :peer_review_cycles do |t|
      t.integer :assignment_id, :null => false
      t.string :distribution_scheme, :null => false
      t.boolean :get_marks, :null => false
      t.boolean :shut_off_submission, :null => false
      t.boolean :anonymise, :null => false
      t.datetime :activation_time

      t.timestamps
    end
  end
end
