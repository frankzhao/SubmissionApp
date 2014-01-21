class PeerReviewCycle < ActiveRecord::Base
  attr_accessible :anonymise, :assignment_id, :distribution_scheme,
                  :shut_off_submission, :activation_time,
                  :maximum_mark

  belongs_to :assignment

  has_many :submission_permissions

  has_many :comments
  has_many :peer_marks, :through => :comments, :source => :peer_marks

  validates :assignment_id, :distribution_scheme, :presence => :true

  before_destroy :delete_children


  DISTRIBUTION_SCHEMES = %w(swap_simultaneously send_to_previous)

  validates :distribution_scheme, :inclusion => { :in => DISTRIBUTION_SCHEMES }

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

  def deactivate!
    if ! self.activated
      throw "I'm not already activated"
    else
      self.activated = false
      self.submission_permissions.delete_all
    end

    self.save!
  end


  # TODO: generalise this for the case where people send their assignments to
  # more than one other student.
  def swap_simultaneously
    submittors = self.assignment.students_who_have_submitted
    mapping = submittors.zip(submittors.shuffle)
    while (mapping.any?{|k,v| k==v}) do
      mapping = submittors.zip(submittors.shuffle)
    end

    mapping.each do |source, destination|
      submission = source.most_recent_submission(self.assignment)
      submission.add_permission(destination, self.id)
    end
    mapping
  end

  def delete_children
    # TODO: can this be made more elegant?
    self.submission_permissions.each {|p| p.destroy }
  end

  def mark_for_submission(submission)
    comments = self.comments.where(:assignment_submission_id => submission.id).order('created_at DESC')

    comments.map { |x| x.peer_mark }.select { |x| x }.first.try(:value)
  end

  def disable_submissions(user)
    return false unless self.disable_submissions

    self.submission_permissions.where(:user_id => user.id).each do |permission|
      if self.comments.where(:user_id => user_id)
                      .where(:assignment_submission_id => permission.assignment_submission_id)
                      .empty?
        return true
      end
    end
    false
  end
    end
  end
end
