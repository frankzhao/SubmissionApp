class Notification < ActiveRecord::Base
  attr_accessible :notable_id, :notable_type, :user_id, :message

  belongs_to :user

  # Citation needed!
  belongs_to :notable, :polymorphic => true


  # This `include` allows me to use path helpers in my model.
  # Some people reckon that it's a bad idea to let the model access this.
  # However, I need to get this link from a variety of places, and it's specific
  # to the notification. So I'm unashamedly doing it this way.
  include Rails.application.routes.url_helpers


  def text
    @text ||= self.message || begin
      case self.notable_type
      when "Comment"
        "You have a new comment on your assignment submission for #{self.notable.assignment.name}"
      when "Assignment"
        "You have a new assignment, #{self.notable.name}, for #{self.notable.group_type.name}"
      when "SubmissionPermission"
        "You've been given a new submission to peer review."
      else
        fail
      end
    end
  end

  def link
    case self.notable_type
    when nil
      "#"
    when "Comment"
      assignment_assignment_submission_path(self.notable.assignment_submission.assignment,
          self.notable.assignment_submission)
    when "Assignment"
      assignment_path(self.notable.id)
    when "SubmissionPermission"
      assignment_assignment_submission_path(self.notable.assignment_submission.assignment,
          self.notable.assignment_submission)
    else
      fail
    end
  end
end

