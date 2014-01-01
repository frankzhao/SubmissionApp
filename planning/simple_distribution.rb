# This file is me planning the assignment distribution.

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

class PreviousStudentMarksAssignment < AssignmentDistributionScheme
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

class NextStudentMarksAssignment < AssignmentDistributionScheme
  def on_submission
    hand_in_to student.tutors.least_busy

    get_amendments_from (submitter_number (submissions_so_far + 1))
  end
end

class LeastBusyCourseTutorMarksAssignment < AssignmentDistributionScheme
  def on_submission
    hand_in_to course.tutors.least_busy
  end
end

# The 1st and 2nd swap, the 3rd and 4th swap, and so on...

class SwapAssignments < AssignmentDistributionScheme
  # 1 <-> 2, 3 <-> 4, etc...
  def swap_even_with_odd(n)
    n / 2 * 4 - n + 1
  end

  def on_submission
    hand_in_to (submitter_number swap_even_with_odd(n))
  end
end

class ComplexAssignmentDistribution < AssignmentDistributionScheme
  due_date "2014/03/07"

  def on_due_date
    students.each do |student|
      if student.has_submitted?
        student.most_recent_submission.hand_in_to student.tutors.least_busy
      else
        send_notification, :to => student, :message => "you haven't submitted!"
        send_notification, :to => tutor, :message => "student didn't submit",
                           :include_context => true
      end
    end
  end

  def on_submission(student, submission)
    system("")
