class Comment < ActiveRecord::Base
  #TODO: nested comments

  attr_accessible :assignment_submission_id, :body, :mark, :user_id

  belongs_to :assignment_submission
  belongs_to :user
end
