class AddMigratedColumn < ActiveRecord::Migration
  def up
    add_column :peer_review_cycles, :activated, :boolean, :default => false
  end
end
