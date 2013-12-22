class User < ActiveRecord::Base
  attr_accessible :name, :session_token, :uni_id

  has_many :student_enrollments
  has_many :student_courses, :through => :student_enrollments, :source => :course

  has_many :staff_enrollments
  has_many :staffed_courses, :through => :staff_enrollments, :source => :course

  has_many :group_student_memberships
  has_many :student_groups, :through => :group_student_memberships, :source => :group

  has_many :group_staff_memberships
  has_many :staffed_groups, :through => :group_staff_memberships, :source => :group

  has_many :convened_courses, :class_name => "Course", :foreign_key => :convenor_id

  before_validation :reset_session_token, :on => :create

  validates :name, :session_token, :uni_id, :presence => true

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
