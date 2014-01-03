class User < ActiveRecord::Base
  attr_accessible :name, :session_token, :uni_id
  attr_protected :admin

  has_many :student_enrollments
  has_many :student_courses, :through => :student_enrollments, :source => :course

  has_many :staff_enrollments
  has_many :staffed_courses, :through => :staff_enrollments, :source => :course

  has_many :group_student_memberships
  has_many :student_groups, :through => :group_student_memberships, :source => :group

  has_many :group_staff_memberships
  has_many :staffed_groups, :through => :group_staff_memberships, :source => :group

  has_many :convened_courses, :class_name => "Course", :foreign_key => :convenor_id

  has_many :assignment_submissions

  before_validation :reset_session_token, :on => :create

  validates :name, :session_token, :uni_id, :presence => true

  def self.create_by_csv!(csv_string)
    lines = csv_string.split("\n")
    lines.each do |line|
      name, uni_id = line
      User.create!(:name => name, :uni_id => uni_id)
    end
  end

  def courses
    self.student_courses + self.staffed_courses + self.convened_courses
  end

  def taught_courses
    self.staffed_courses + self.convened_courses
  end

  def relationship_to_course(course)
    if self.student_courses.includes?(course)
      :student
    elsif self.taught_courses.includes?(course)
      :staff
    else
      nil
    end
  end

  def relationship_to_assignment(assignment)
    if self.staffed_courses & assignment.courses != []
      :staff
    elsif self.student_courses & assignment.courses != []
      :student
    elsif self.convened_courses & assignment.courses != []
      :convenor
    end
  end

  def most_recent_submission(assignment)
    self.assignment_submissions
        .where(:assignment_id => assignment.id)
        .order('created_at DESC')
        .first
  end

  def reset_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end

  def reset_session_token!
    reset_session_token
    self.save!
  end

  def enroll_in_course!(course)
    StudentEnrollment.create!(:course_id => course.id, :user_id => self.id)
  end

  def enroll_staff_in_course!(course)
    StaffEnrollment.create!(:course_id => course.id, :user_id => self.id)
  end

  def join_group!(group)
    GroupStudentMembership.create!(:group_id => group.id, :user_id => self.id)
  end

  def join_group_as_staff!(group)
    GroupStaffMembership.create!(:group_id => group.id, :user_id => self.id)
  end
end
