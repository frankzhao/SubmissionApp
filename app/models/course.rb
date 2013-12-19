class Course < ActiveRecord::Base
  attr_accessible :name

  validates :name, :presence => true, :uniqueness => true

  belongs_to :course_convenor, :class_name => "user"

  has_many :student_enrollments
  has_many :students, :through => :student_enrollments

  has_many :staff_enrollments
  has_many :staff, :through => :staff_enrollments
end
