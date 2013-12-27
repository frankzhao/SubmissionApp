class AssignmentSubmission < ActiveRecord::Base
  attr_accessible :assignment_id, :body, :user_id

  belongs_to :assignment
  belongs_to :user

  has_one :group_type, :through => :assignment, :source => :group_type

  validates :assignment_id, :user_id, :presence => true

  def permits?(user)
    permitted_people = ([self.user] +
                        assignment.courses.map(&:staff).flatten +
                        assignment.courses.map(&:convenor))

    permitted_people.include?(user)
  end

  def group
    #TODO: this is horribly inefficient. Rewrite it properly.
    self.user.student_groups.each do |group|
      if group.group_type == self.assignment.group_type
        return group
      end
    end
  end

  # This is all the people who are permitted to see the assignment.
  # TODO: make it so that the assignment has a setting to let all
  # staff for the course see all the assignments.
  def staff
    group.staff + group.group_type.courses.map(&:convenor)
  end

  def url
    assignment_assignment_submission_url(
                        self.assignment_id, self.id)
  end

end
