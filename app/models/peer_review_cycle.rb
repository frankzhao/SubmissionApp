class PeerReviewCycle < ActiveRecord::Base
  attr_accessible :anonymise, :assignment_id, :distribution_scheme,
                  :get_marks, :shut_off_submission, :activation_time

  belongs_to :assignment

  validates :anonymise, :assignment_id, :distribution_scheme,
           :get_marks, :shut_off_submission, :presence => :true

  validates :distribution_scheme, :inclusion => { :in => DISTRIBUTION_SCHEMES }

  DISTRIBUTION_SCHEMES = %w(swap_simultaneously send_to_previous)

  def activate!
    if self.activated
      throw "I've already been activated"
    else
      case self.distribution_scheme
      when "swap_simultaneously"
        self.swap_simultaneously
        self.activated = true
      when "send_to_previous"
        raise "not implemented yet" # TODO
      end
    end

    self.save!
  end

  # TODO: generalise this for the case where people send their assignments to
  # more than one other student.
  def swap_simultaneously
    submittors = self.students_who_have_submitted
    mapping = submittors.zip(submittors.shuffle)
    while (mapping.any?{|k,v| k==v}) do
      mapping = submittors.zip(submittors.shuffle)
    end

    mapping.each do |source, destination|
      submission = source.most_recent_submission(self)
      submission.add_permission(destination)
    end
    mapping
  end
end
