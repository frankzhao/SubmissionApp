class Course < ActiveRecord::Base
  attr_accessible :name

  validates :name, :presence => true, :uniqueness => true

  belongs_to :convenor, :class_name => "User"

  has_many :student_enrollments
  has_many :students, :through => :student_enrollments, :source => :user

  has_many :staff_enrollments
  has_many :staff, :through => :staff_enrollments, :source => :user

  has_many :group_course_memberships
  has_many :group_types, :through => :group_course_memberships,
                         :source => :group_type

  has_many :assignments, :through => :group_types,
                         :source => :assignments
end
