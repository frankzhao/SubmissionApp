class AssignmentCourseMembership < ActiveRecord::Base
  attr_accessible :assignment_id, :course_id, :course, :assignment

  belongs_to :assignment
  belongs_to :course
end
