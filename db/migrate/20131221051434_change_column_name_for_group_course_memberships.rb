class ChangeColumnNameForGroupCourseMemberships < ActiveRecord::Migration
  def change
    rename_column :group_course_memberships, :group_id, :group_type_id
  end
end
