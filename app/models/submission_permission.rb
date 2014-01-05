class SubmissionPermission < ActiveRecord::Base
  attr_accessible :assignment_submission_id, :user_id

  belongs_to :assignment_submission
  belongs_to :user


end
