class AddMoreNullContraints < ActiveRecord::Migration
  def change
    change_column :assignment_submissions, :assignment_id, :integer, :null => false
    change_column :assignment_submissions, :body, :string, :null => false
    change_column :assignments, :group_type_id, :integer, :null => false
    change_column :group_course_memberships, :course_id, :integer, :null => false
    change_column :group_course_memberships, :group_type_id, :integer, :null => false
    change_column :staff_enrollments, :user_id, :integer, :null => false
    change_column :staff_enrollments, :course_id, :integer, :null => false
    change_column :student_enrollments, :user_id, :integer, :null => false
    change_column :student_enrollments, :course_id, :integer, :null => false
  end
end
