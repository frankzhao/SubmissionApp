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
        "New comment"
      when "Assignment"
        "New assignment: #{self.notable.name}"
      when "SubmissionPermission"
        "New peer submission"
      else
        fail
      end
    end
  end

  def link
    if self.notable.nil?
      self.destroy
      return "#"
    end

    case self.notable_type
    when nil
      notification_path(self)
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

