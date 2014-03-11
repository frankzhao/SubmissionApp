class Notification < ActiveRecord::Base
  attr_accessible :notable_id, :notable_type, :user_id, :message

  belongs_to :user

  # Citation needed!
  belongs_to :notable, :polymorphic => true

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
end

