# This file is me planning the assignment distribution.

tutors = group_staff

class AssignmentDistributionScheme
  def add_marker; end # takes notify
  def student; end
end

# Marks has: average, weight_by

class TutorsMarkAssignments < AssignmentDistributionScheme
  def on_submission
    hand_in_to student.tutors
  end

  # This might as well be the default...
  def calculate_mark
    marks.average
  end
end


# Give to another student

class PreviousStudentMarksAssignment
  def on_submission
    hand_in_to student.tutors

    if submissions.length == 0
      get_feedback_from student.tutors.first
    else
      most_recently_submitting_student = submissions.last.student
      get_feedback_from most_recently_submitting_student, :anonymous => true
    end
  end
end

class NextStudentMarksAssignment
  def on_submission
    hand_in_to student.tutors.least_busy

    get_amendments_from (submitter_number (submissions_so_far + 1))
  end
end

class LeastBusyCourseTutorMarksAssignment
  def on_submission
    hand_in_to course.tutors.least_busy
  end
end

# The 1st and 2nd swap, the 3rd and 4th swap, and so on...

class SwapAssignments
  # 1 <-> 2, 3 <-> 4, etc...
  def swap_even_with_odd(n)
    n / 2 * 4 - n + 1
  end

  def on_submission
    hand_in_to (submitter_number swap_even_with_odd(n))
  end
end

# Everyone is given to three others after the due date
class SwapAssignments
  def
end

