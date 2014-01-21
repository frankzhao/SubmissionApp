class PeerMark < ActiveRecord::Base
  attr_accessible :comment_id, :value

  belongs_to :comment
  delegate :peer_review_cycle, :to => :comment
end
