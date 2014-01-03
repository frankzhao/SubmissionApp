class GroupType < ActiveRecord::Base
  attr_accessible :name, :courses, :groups

  has_many :group_course_memberships
  has_many :courses, :through => :group_course_memberships, :source => :course

  has_many :groups
  has_many :assignments

  has_many :students, :through => :group, :source => :students

  def create_groups(group_hash)
    [].tap do |groups|
      group_hash.each do |name, staff|
        group = Group.create(:name => name, :group_type_id => self.id)
        staff.each do |user|
          user.join_group_as_staff!(group)
        end
        groups << group
      end
    end
  end
end
