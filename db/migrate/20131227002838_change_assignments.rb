class ChangeAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :group_type_id, :integer

    drop_table :assignment_course_memberships

  end
end
