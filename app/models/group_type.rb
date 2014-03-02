class GroupType < ActiveRecord::Base
  attr_accessible :name, :courses, :groups

  has_many :group_course_memberships
  has_many :courses, :through => :group_course_memberships, :source => :course

  has_many :groups
  has_many :assignments

  has_many :students, :through => :groups, :source => :students
  has_many :staff, :through => :groups, :source => :staff
  has_many :conveners, :through => :courses, :source => :convener

  validates :name, uniqueness: true

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

  def add_course!(course)
    GroupCourseMembership.create!(:group_type_id => self.id, :course_id => course.id)
  end

  def update_student_membership(user, group_name)
    current_group = user.student_groups
                        .where(:group_type_id => self.id)
                        .first

    if current_group.nil?
      unless group_name == "" || group_name.nil?
        user.join_group!(Group.touch(group_name, self))
        return {:joins => 1, :changes => 0}
      end
    else
      unless group_name == current_group.name
        user.drop_group!(current_group)
        user.join_group!(Group.touch(group_name, self))
        return {:changes => 1, :joins => 0}
      end
    end
    Hash.new(0)
  end

  def update_staff_membership(user, group_name)
    current_group = user.staffed_groups
                        .where(:group_type_id => self.id)
                        .first

    if current_group.nil?
      unless group_name == ""
        user.join_group_as_staff!(Group.touch(group_name, self))
      end
    else
      unless group_name == current_group.name
        user.drop_group_as_staff!(current_group)
        user.join_group_as_staff!(Group.touch(group_name, self))
        self.courses.each do |course|
          user.enroll_staff_in_course(course)
        end
      end
    end
  end

  def render_csv
    out = ["group name,staff..."]
    self.groups.each do |group|
      row = []
      row << group.name
      row += group.staff.map(&:uni_id)
      out << row.join(",")
    end
    return out.join("\n")
  end

  def edit_by_csv(csv_string)
    ActiveRecord::Base.transaction do
      lines = csv_string.split("\n")

      unless "group name,staff..." == lines[0].chomp
        raise "invalid csv"
      end

      groups_seen = []
      puts "\n"*30

      lines.drop(1).each do |line|
        row = line.chomp.split(",")
        g = Group.touch(row[0], self)
        g.jettison_staff
        row.drop(1).uniq.each do |staff_uni_id|
          u = User.find_by_uni_id(staff_uni_id)
          u.join_group_as_staff!(g)
        end
        groups_seen << g
      end
      (self.groups - groups_seen).map(&:delete)
    end
  end

  def students_of_courses
    where_clause = <<-SQL
    student_enrollments.course_id IN
        (SELECT courses.id
          FROM courses
          JOIN group_course_memberships
          ON courses.id = group_course_memberships.course_id
          WHERE group_course_memberships.group_type_id = #{self.id})
    SQL

    User.joins(:student_enrollments).where(where_clause)
  end

  def students_without_a_group_count
    self.students_of_courses.count - self.students.count
  end
end
