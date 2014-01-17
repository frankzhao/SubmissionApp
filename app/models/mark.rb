class Mark < ActiveRecord::Base
  attr_accessible :comment_id, :marking_category_id, :value

  validates :comment_id, :marking_category_id, :value, :presence => true

  belongs_to :marking_category
  belongs_to :comment
  delegate :assignment_submission, :to => :comment
end
