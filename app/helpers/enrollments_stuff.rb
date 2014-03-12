module EnrollmentsStuff
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
end