class Comment < ActiveRecord::Base
  #TODO: nested comments

  attr_accessible :assignment_submission_id, :body, :user_id

  belongs_to :assignment_submission
  delegate :assignment, :to => :assignment_submission

  belongs_to :user

  has_many :marks

  validates :assignment_submission_id, :body, :user_id, :presence => true
end
