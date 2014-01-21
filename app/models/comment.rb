class Comment < ActiveRecord::Base
  #TODO: nested comments

  attr_accessible :assignment_submission_id, :body, :user_id, :peer_review_cycle_id

  belongs_to :assignment_submission
  delegate :assignment, :to => :assignment_submission

  belongs_to :user
  belongs_to :peer_review_cycle

  has_many :marks

  has_one :peer_mark

  validates :assignment_submission_id, :body, :user_id, :presence => true
end
