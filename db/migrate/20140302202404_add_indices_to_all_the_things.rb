class AddIndicesToAllTheThings < ActiveRecord::Migration
  def change
    add_index :assignment_submissions, :assignment_id
    add_index :assignment_submissions, :user_id

    add_index :assignments, :group_type_id

    add_index :comments, :assignment_submission_id
    add_index :comments, :peer_review_cycle_id
    add_index :comments, :parent_id
    add_index :comments, :user_id

    add_index :group_course_memberships, :course_id
    add_index :group_course_memberships, :group_type_id

    add_index :group_staff_memberships, :group_id
    add_index :group_staff_memberships, :user_id

    add_index :group_student_memberships, :group_id
    add_index :group_student_memberships, :user_id

    add_index :groups, :group_type_id

    add_index :marking_categories, :assignment_id

    add_index :marks, :comment_id

    add_index :peer_marks, :comment_id

    add_index :peer_review_cycles, :assignment_id

    add_index :staff_enrollments, :user_id
    add_index :staff_enrollments, :course_id

    add_index :student_enrollments, :user_id
    add_index :student_enrollments, :course_id

    add_index :submission_permissions, :assignment_submission_id
    add_index :submission_permissions, :user_id
    add_index :submission_permissions, :peer_review_cycle_id

    add_index :users, :uni_id
  end
end
