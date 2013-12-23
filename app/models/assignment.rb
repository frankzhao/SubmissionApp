class Assignment < ActiveRecord::Base
  attr_accessible :info, :name

  has_many :assignment_course_memberships
  has_many :courses, :through => :assignment_course_memberships,
                         :source => :course

  def add_course(course)
    AssignmentCourseMembership.create(:course_id => course.id,
                                      :assignment_id => self.id)

end
