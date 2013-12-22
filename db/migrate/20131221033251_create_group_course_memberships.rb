class CreateGroupCourseMemberships < ActiveRecord::Migration
  def change
    create_table :group_course_memberships do |t|
      t.integer :course_id
      t.integer :group_id

      t.timestamps
    end
  end
end
