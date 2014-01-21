class PeerReviewCycle < ActiveRecord::Base
  attr_accessible :anonymise, :assignment_id, :distribution_scheme,
                  :shut_off_submission, :activation_time,
                  :maximum_mark

  belongs_to :assignment

  has_many :submission_permissions

  has_many :comments
  has_many :peer_marks, :through => :comments, :source => :peer_mark

  validates :assignment_id, :distribution_scheme, :presence => :true

  before_destroy :delete_children

  DISTRIBUTION_SCHEMES = %w(swap_simultaneously send_to_previous)

  validates :distribution_scheme, :inclusion => { :in => DISTRIBUTION_SCHEMES }

  def activate!
    if self.activated
      throw "I've already been activated"
    elsif self.submission_permissions.empty?
      case self.distribution_scheme
      when "swap_simultaneously"
        p "swapping swap_simultaneously"
        self.swap_simultaneously
        p "finished swap"
      when "send_to_previous"
        # do nothing, I think...?
      end
    end

    self.activated = true
    self.save!
  end

  def deactivate!
    if ! self.activated
      throw "I'm not already activated"
    else
      self.activated = false
    end

    self.save!
  end


  # TODO: generalise this for the case where people send their assignments to
  # more than one other student.
  def swap_simultaneously
    submittors = self.assignment.students_who_have_submitted.uniq
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
    self.peer_marks.each {|p| p.destroy }
    self.comments.each {|p| p.destroy }
  end

  def mark_for_submission(submission)
    comments = self.comments.where(:assignment_submission_id => submission.id).order('created_at DESC')

    comments.map { |x| x.peer_mark }.select { |x| x }.first.try(:value)
  end

  def disable_submissions(user)
    return false unless self.shut_off_submission

    self.submission_permissions.where(:user_id => user.id).each do |permission|
      unless permission.assignment_submission.commented_on_by_user?(user)
        return true
      end
    end
    false
  end

  def receive_submission(submission)
    if self.distribution_scheme == "send_to_previous"
      send_to_previous(submission)
    end
  end

  def send_to_previous(submission)

    user_submissions =  self.assignment
                            .submissions
                            .where("created_at > ?", self.activation_time)
                            .where(:user_id => submission.user)

    puts ("User submissions are "+user_submissions.all.to_s)

    return unless user_submissions.length == 1

    previous_users = self.assignment
                         .submissions
                         .where("created_at > ?", self.activation_time)
                         .order('created_at DESC')
                         .map { |s| s.user }

    previous_users.each do |previous_user|
      next if submission.user == previous_user
      if self.permitted_submissions_for_user(previous_user).empty?
        p "*"*100
        submission.add_permission(previous_user, self.id)
        return
      end
    end

    submission.add_permission(assignment.conveners.first, self.id)
  end

  def permitted_submissions_for_user(user)
    self.submission_permissions.where(:user_id => user.id).map do |x|
      x.assignment_submission
    end
  end

end
