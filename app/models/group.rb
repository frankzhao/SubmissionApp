class Group < ActiveRecord::Base
  attr_accessible :name, :group_type_id, :group_type

  belongs_to :group_type
  has_many :courses, :through => :group_type, :source => :courses

  has_many :group_student_memberships
  has_many :students, :through => :group_student_memberships, :source => :user

  has_many :group_staff_memberships
  has_many :staff, :through => :group_staff_memberships, :source => :user

  has_many :assignments, :through => :group_type, :source => :assignment

  def self.touch(group_type, name)
    g = Group.find_by_name_and_group_type_id(name, group_type.id)
    return g if g
    Group.create!(:group_type => group_type, :name => name)
  end

  def submissions(assignment)
    # TODO: rewrite this as SQL
    assignment.submissions.select do |submission|
      self.students.include?(submission.user)
    end
  end

  def jettison_staff
    GroupStaffMembership.delete_all(:group_id => self.id)
  end
end
