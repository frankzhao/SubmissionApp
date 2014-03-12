module UserAssignmentRelationshipStuff
  def relationship_to_assignment(assignment)
    if self.staffed_courses & assignment.courses != []
      :staff
    elsif self.student_courses & assignment.courses != []
      :student
    elsif self.convened_courses & assignment.courses != []
      :convener
    end
  end

  def most_recent_submission(assignment)
    self.assignment_submissions
        .where(:assignment_id => assignment.id)
        .order('created_at DESC')
        .first
  end

  #TODO: SQL
  def permitted_submissions_for_assignment(assignment)
    self.submission_permissions.includes(:assignment)
                               .includes(:peer_review_cycle)
                               .select { |s| s.assignment == assignment }
                               .select { |s| s.peer_review_cycle.activated }
                               .map(&:assignment_submission)
  end

  def all_assignments
    @all_assignments ||= begin
      if self.is_admin
        Assignment.all
      else
        (self.student_assignments.visible + self.staffed_assignments +
          self.convened_assignments).uniq
      end
    end
  end

  # this is the submissions which you need to comment on
  def uncommented_submissions
    self.permitted_submissions.uncommented(self)
  end

  def uncommented_submissions_for_assignment(assignment)
    self.permitted_submissions.where_assignment_is(assignment).uncommented(self)
  end

  def permitted_submissions_for_assignment(assignment)
    self.permitted_submissions.where_assignment_is(assignment)
  end

  def has_uncommented_submissions_for_assignment?(assignment)
    self.permitted_submissions.where_assignment_is(assignment).uncommented(self).count > 0
  end

  def staffed_and_convened_assignments
    self.staffed_assignments + self.convened_assignments
  end

  def has_submitted_for_assignment(assignment)
    (self.assignment_submissions
        .where(:assignment_id => assignment.id)
        .count) > 0
  end

  def has_finalized_for_assignment(assignment)
    (self.assignment_submissions
        .where(:assignment_id => assignment.id)
        .where(:is_finalized => true)
        .count) > 0
  end
end