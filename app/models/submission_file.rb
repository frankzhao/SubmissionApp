class SubmissionFile < ActiveRecord::Base
  attr_accessible :assignment_submission_id, :body, :name

  belongs_to :assignment_submission
end
