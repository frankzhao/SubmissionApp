class CreateGroupStaffMemberships < ActiveRecord::Migration
  def change
    create_table :group_staff_memberships do |t|
      t.integer :user_id, :null => false
      t.integer :group_id, :null => false

      t.timestamps
    end
  end
end
