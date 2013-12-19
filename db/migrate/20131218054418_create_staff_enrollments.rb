class CreateStaffEnrollments < ActiveRecord::Migration
  def change
    create_table :staff_enrollments do |t|
      t.integer :user_id
      t.integer :course_id

      t.timestamps
    end
  end
end
