class GroupCourseMembership < ActiveRecord::Base
  attr_accessible :course_id, :group_type_id

  belongs_to :course
  belongs_to :group_type
end
