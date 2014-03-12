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
      when "comment"
        "You have a new comment on your assignment submission for #{self.notable.assignment.name}"
      when "assignment"
        "You have a new assignment, #{self.notable.name}, for #{self.notable.group_type.name}"
      when "submission_permission"
        "You've been given a new submission to peer review."
      end
    end
  end

  def link
    case self.notable_type
    when nil
      notification_url(self)
    when "comment"
      url_for([self.notable.assignment_submission.assignment,
          self.notable.assignment_submission])
    when "assignment"
      url_for(self.notable)
    when "submission_permission"
      url_for([self.notable.assignment_submission.assignment,
          self.notable.assignment_submission])
    end
  end
end

