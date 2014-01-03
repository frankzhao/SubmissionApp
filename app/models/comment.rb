class Comment < ActiveRecord::Base
  attr_accessible :assignment_submission_id, :body, :mark, :user_id

  belongs_to :assignment_submission
  belongs_to :user
end
