class Course < ActiveRecord::Base
  attr_accessible :name, :convener_id

  validates :name, :presence => true, :uniqueness => true

  belongs_to :convener, :class_name => "User"

  has_many :student_enrollments
  has_many :students, :through => :student_enrollments, :source => :user

  has_many :staff_enrollments
  has_many :staff, :through => :staff_enrollments, :source => :user

  has_many :group_course_memberships
  has_many :group_types, :through => :group_course_memberships,
                         :source => :group_type

  has_many :assignments, :through => :group_types,
                         :source => :assignments

  def add_students_by_csv(csv_string)
    students = User.create_by_csv!(csv_string)
    students.each do |student|
      student.enroll_in_course!(self)
    end
  end

  def admin_or_convener?(user)
    user.is_admin || self.convener == user
  end
end
