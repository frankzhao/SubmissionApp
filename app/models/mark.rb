class Mark < ActiveRecord::Base
  attr_accessible :comment_id, :marking_category_id, :value

  validates :comment_id, :marking_category_id, :value, :presence => true
  validates :value, numericality: { only_integer: true }
  validate :mark_is_within_range

  belongs_to :marking_category
  belongs_to :comment
  delegate :assignment_submission, :to => :comment

  def mark_is_within_range
    if self.value > self.marking_category.maximum_mark
      self.errors[:value] << 'That mark is higher than the maximum mark.'
    end
    if self.value < 0
      self.errors[:value] << "You can't award negative marks. If the submission" +
                               " is literally worse than nothing, talk to your "+
                               "convener or something."
    end
  end
end
