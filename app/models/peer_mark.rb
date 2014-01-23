class PeerMark < ActiveRecord::Base
  attr_accessible :comment_id, :value

  belongs_to :comment
  delegate :peer_review_cycle, :to => :comment

  validates :value, :presence => true
  validate :mark_is_within_range


  def mark_is_within_range
    if self.value > self.peer_review_cycle.maximum_mark
      self.errors[:value] << 'That mark is higher than the maximum mark.'
    end
    if self.value < 0
      self.errors[:value] << "You can't award negative marks. If the submission" +
                               " is literally worse than nothing, talk to your "+
                               "convener or something."
    end
  end
end
