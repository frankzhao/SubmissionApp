class PeerReviewCycle < ActiveRecord::Base
  attr_accessible :anonymise, :assignment_id, :distribution_scheme,
                  :get_marks, :shut_off_submission, :activation_time

  belongs_to :assignment

  validates :anonymise, :assignment_id, :distribution_scheme,
           :get_marks, :shut_off_submission, :presence => :true

  validates :distribution_scheme, :inclusion => { :in => DISTRIBUTION_SCHEMES }

  DISTRIBUTION_SCHEMES = %w(swap_simultaneously send_to_previous)
end
