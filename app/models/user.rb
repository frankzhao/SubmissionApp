class User < ActiveRecord::Base
  attr_accessible :name, :session_token, :uni_id
  attr_protected :admin

  has_many :student_enrollments, :dependent => :destroy
  has_many :student_courses, :through => :student_enrollments, :source => :course
  has_many :student_assignments, :through => :student_courses, :source => :assignments

  has_many :staff_enrollments, :dependent => :destroy
  has_many :staffed_courses, :through => :staff_enrollments, :source => :course
  has_many :staffed_assignments, :through => :staffed_courses, :source => :assignments

  has_many :group_student_memberships, :dependent => :destroy
  has_many :student_groups, :through => :group_student_memberships, :source => :group

  has_many :group_staff_memberships, :dependent => :destroy
  has_many :staffed_groups, :through => :group_staff_memberships, :source => :group

  has_many :convened_courses, :class_name => "Course", :foreign_key => :convener_id
  has_many :convened_assignments, :through => :convened_courses, :source => :assignments

  has_many :assignment_submissions, :dependent => :destroy

  has_many :group_types, :through => :student_groups, :source => :group_type
  has_many :assignments, :through => :group_types, :source => :assignments

  has_many :staffed_group_types, :through => :staffed_courses, :source => :group_types
  has_many :staffed_assignments, :through => :staffed_group_types, :source => :assignments

  has_many :submission_permissions, :dependent => :destroy
  has_many :permitted_submissions, :through => :submission_permissions,
                                   :source => :assignment_submission

  has_many :notifications, :dependent => :destroy

  has_many :comments, :dependent => :destroy

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

  include EnrollmentsStuff

  include UserAssignmentRelationshipStuff

  def reset_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end

  def reset_session_token!
    reset_session_token
    self.save!
  end
end