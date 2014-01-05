class SubmissionPermission < ActiveRecord::Base
  attr_accessible :assignment_submission_id, :user_id

  belongs_to :assignment_submission
  has_one :assignment, :through => :assignment_submission, :source => :assignment
  belongs_to :user


end
