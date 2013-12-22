class CreateStaffEnrollments < ActiveRecord::Migration
  def change
    create_table :staff_enrollments do |t|
      t.integer :user_id, :null => false
      t.integer :course_id, :null => false

      t.timestamps
    end
  end
end
