class SubmissionFile < ActiveRecord::Base
  attr_accessible :assignment_submission_id, :body, :name, :file_blob

  belongs_to :assignment_submission
end
