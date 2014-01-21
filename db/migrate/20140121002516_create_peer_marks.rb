class CreatePeerMarks < ActiveRecord::Migration
  def change
    create_table :peer_marks do |t|
      t.integer :comment_id, :null => false
      t.integer :value, :null => false

      t.timestamps
    end
  end
end
