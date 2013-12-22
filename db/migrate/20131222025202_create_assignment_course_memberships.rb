class CreateAssignmentCourseMemberships < ActiveRecord::Migration
  def change
    create_table :assignment_course_memberships do |t|
      t.integer :assignment_id, :null => false
      t.integer :course_id, :null => false

      t.timestamps
    end
  end
end
