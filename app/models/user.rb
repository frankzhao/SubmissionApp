class User < ActiveRecord::Base
  attr_accessible :name, :session_token, :uni_id
  attr_protected :admin

  has_many :student_enrollments
  has_many :student_courses, :through => :student_enrollments, :source => :course
  has_many :student_assignments, :through => :student_courses, :source => :assignments

  has_many :staff_enrollments
  has_many :staffed_courses, :through => :staff_enrollments, :source => :course
  has_many :staffed_assignments, :through => :staffed_courses, :source => :assignments

  has_many :group_student_memberships
  has_many :student_groups, :through => :group_student_memberships, :source => :group

  has_many :group_staff_memberships
  has_many :staffed_groups, :through => :group_staff_memberships, :source => :group

  has_many :convened_courses, :class_name => "Course", :foreign_key => :convener_id
  has_many :convened_assignments, :through => :convened_courses, :source => :assignments

  has_many :assignment_submissions

  has_many :group_types, :through => :student_groups, :source => :group_type
  has_many :assignments, :through => :group_types, :source => :assignments

  has_many :staffed_group_types, :through => :staffed_courses, :source => :group_types
  has_many :staffed_assignments, :through => :staffed_group_types, :source => :assignments

  has_many :submission_permissions
  has_many :permitted_submissions, :through => :submission_permissions,
                                   :source => :assignment_submission

  has_many :notifications

  before_validation :reset_session_token, :on => :create

  validates :name, :session_token, :uni_id, :presence => true

  def self.create_by_csv!(csv_string)
    lines = csv_string.split("\n").map(&:strip).map{ |line| line.split(",") }

    raise "Invalid csv!" if lines[0]!=["name","uni id"]

    [].tap do |out|
      lines[1..-1].each do |line|
        name, uni_id = line
        user = User.find_by_uni_id(uni_id)
        if !user
          user = User.create!(:name => name, :uni_id => uni_id)
        end
        out << user
      end
    end
  end

  def self.touch(name, uni_id)
    user = User.find_by_uni_id(uni_id)
    return user if user
    User.create!(:name => name, :uni_id => uni_id)
  end

  def is_convener?
    ! self.convened_courses.empty?
  end

  def is_admin_or_convener?
    self.is_admin || self.is_convener?
  end

  def courses
    self.student_courses + self.staffed_courses + self.convened_courses
  end

  def taught_courses
    self.staffed_courses + self.convened_courses
  end

  def relationship_to_course(course)
    if self.student_courses.include?(course)
      :student
    elsif self.taught_courses.include?(course)
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
      :convener
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
    if self.student_courses.include? course
      false
    else
      StudentEnrollment.create!(:course_id => course.id, :user_id => self.id)
      true
    end
  end

  def drop_course!(course)
    course.group_types.each do |group_type|
      self.drop_group_type!(group_type)
    end

    StudentEnrollment.find_by_user_id_and_course_id(self.id, course.id)
                     .try(:destroy)
  end

  def enroll_staff_in_course!(course)
    unless self.staffed_courses.include? course
      StaffEnrollment.create!(:course_id => course.id, :user_id => self.id)
    end
  end

  def join_group!(group)
    unless self.student_groups.include?(group)
      GroupStudentMembership.create!(:group_id => group.id, :user_id => self.id)
    end
  end

  def drop_group!(group)
    GroupStudentMembership.find_by_user_id_and_group_id(self.id, group.id)
                     .try(:destroy)
  end

  def drop_group_type!(group_type)
    self.student_groups.each do |group|
      self.drop_group!(group) if group.group_type == group_type
      return 1
    end
    return 0
  end

  def join_group_as_staff!(group)
    unless self.student_groups.include?(group)
      GroupStaffMembership.create!(:group_id => group.id, :user_id => self.id)
    end
  end

  def drop_group_as_staff!(group)
    GroupStaffMembership.find_by_user_id_and_group_id(self.id, group.id)
                          .try(:destroy)
  end


  #TODO: SQL
  def permitted_submissions_for_assignment(assignment)
    self.submission_permissions.includes(:assignment)
                               .includes(:peer_review_cycle)
                               .select { |s| s.assignment == assignment }
                               .select { |s| s.peer_review_cycle.activated }
                               .map(&:assignment_submission)
  end

  def all_assignments
    @all_assignments ||= (self.student_assignments + self.staffed_assignments +
        self.convened_assignments).uniq
  end

  # this is the submissions which you need to comment on
  def uncommented_submissions
    self.permitted_submissions.uncommented(self)
  end

  def staffed_and_convened_assignments
    self.staffed_assignments + self.convened_assignments
  end
end
