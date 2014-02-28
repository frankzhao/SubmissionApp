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

  extend FriendlyId

  friendly_id :name, :use => :slugged

  def add_students_by_csv(csv_string)
    output = Hash.new(0)
    ActiveRecord::Base.transaction do
      lines = csv_string.split("\n")

      correct_first_line = "name,uni id" + self.group_types.map{|x| ",#{x.name}"}
                                              .join("")

      unless correct_first_line == lines[0].chomp
        raise "The first line of the staff csv was wrong. It should be 'name,uni id'."
      end

      users_seen = []

      lines.drop(1).each do |line|
        row = line.chomp.split(",")
        u = User.touch(row[0], row[1])
        new_enroll = u.enroll_in_course!(self)
        output["New enrollments"] += 1 if new_enroll

        self.group_types.zip(row.drop(2)).each do |group_type, group_name|
          if group_name.nil? || group_name.length == 0
            output["Students dropping groups"] += u.drop_group_type!(group_type)
            next
          end
          details = group_type.update_student_membership(u, group_name)
          output["Students joining groups"] += details[:joins]
          output["Students changing groups"] += details[:changes]
        end
        users_seen << u
      end

      (self.students - users_seen).each do |failed_student|
        output["Students removed"] += 1
        failed_student.drop_course!(self)
      end
    end
    return output
  end

  def add_staff_by_csv(csv_string)
    original_staff = self.staff.to_a
    ActiveRecord::Base.transaction do
      lines = csv_string.split("\n")
      unless lines.first == "name,uni id"
        raise "The first line of the staff csv was wrong. It should be 'name,uni id'."
      end

      StaffEnrollment.delete_all(:course_id => self.id)

      lines.drop(1).each do |line|
        row = line.chomp.split(",")

        u = User.touch(row[0], row[1])
        u.enroll_staff_in_course!(self)
      end
    end
    output = {}

    new_staff = Course.find_by_id(self.id).staff
    output["Staff added"] = (new_staff - original_staff).length
    output["Staff removed"] = (original_staff - new_staff).length
    output
  end

  def admin_or_convener?(user)
    user.is_admin || self.convener == user
  end

  def render_student_csv
    out = []

    out << "name,uni id," + self.group_types.map(&:name).join(",")
    self.students.each do |student|
      row = [student.name, student.uni_id.to_s]
      self.group_types.each do |group_type|
        row << student.student_groups.find_by_group_type(group_type).first.try(:name)
      end
      out << row.join(",")
    end
    out.join("\n")
  end

  def render_staff_csv
    out = []
    out << "name,uni id"
    self.staff.each do |staff|
      row = [staff.name, staff.uni_id.to_s]
      out << row.join(",")
    end
    out.join("\n")
  end
end