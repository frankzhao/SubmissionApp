class Assignment < ActiveRecord::Base
  attr_accessible :info, :name

  has_many :assignment_course_memberships
  has_many :courses, :through => :assignment_course_memberships,
                         :source => :course

  has_many :submissions, :class_name => "AssignmentSubmission"

  def add_course(course)
    AssignmentCourseMembership.create(:course_id => course.id,
                                      :assignment_id => self.id)
  end

  def add_courses(*courses)
    courses.each { |course| add_course(course) }
  end
end
