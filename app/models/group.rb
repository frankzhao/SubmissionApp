class Group < ActiveRecord::Base
  attr_accessible :name, :group_type_id, :group_type

  belongs_to :group_type
  has_many :courses, :through => :group_type, :source => :courses

  has_many :group_student_memberships
  has_many :students, :through => :group_student_memberships, :source => :user

  has_many :group_staff_memberships
  has_many :staff, :through => :group_staff_memberships, :source => :user

  has_many :assignments, :through => :group_type, :source => :assignment

  def self.by_group_type(type)
    where(group_type_id: type.id)
  end

  # do
  #   def find_by_group_type(group_type)
  #     where(:group_type_id => group_type.id)
  #   end
  # end


  def self.touch(name, group_type)
    g = Group.find_by_name_and_group_type_id(name, group_type.id)
    return g if g
    Group.create!(:group_type => group_type, :name => name)
  end

  def submissions(assignment)
    self.
    # TODO: rewrite this as SQL
    assignment.submissions.select do |submission|
      self.students.include?(submission.user)
    end
  end

  def jettison_staff
    GroupStaffMembership.delete_all(:group_id => self.id)
  end

  def progress_bar_hash(assignment)
    {}.tap do |out|
      number_students = self.students.count
      return Hash.new(0) if number_students == 0
      number_marked = assignment.submissions
                                .where("user_id IN (#{self.student_ids.join(",")})")
                                .select { |s| s.marks.count > 0  }
                                .length

      number_submitted = assignment.submissions
                                     .where("user_id IN (#{self.student_ids.join(",")})")
                                     .group(:user_id).count.count

      number_finalized = assignment.submissions
                                      .where("user_id IN (#{self.student_ids.join(",")})")
                                      .where(:is_finalized => true)
                                      .group(:user_id).count.count

      if number_marked > number_finalized
        out[:percent_finalized] = 0
        out[:percent_submitted] = [0, (number_submitted - number_marked
                              - number_finalized)].max * 100 / number_students
      else
        out[:percent_finalized] = (number_finalized - number_marked) * 100 / number_students
        out[:percent_submitted] = ((number_submitted - number_finalized) * 100 / number_students)
      end

      out[:percent_marked] = ([number_marked, number_submitted].min * 100 / number_students)
      out[:percent_not_submitted] = (100 - [out[:percent_submitted], out[:percent_marked]].max)
    end
  end
end
