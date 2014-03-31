module PeerReviewHelper
  def add_permission(user, cycle_id)
    SubmissionPermission.create!(:user_id => user.id,
                                 :assignment_submission_id => self.id,
                                 :peer_review_cycle_id => cycle_id)
  end

  def context_name(user_to_be_named, current_user)
    peer_review_cycle = which_peer_review_cycle(user_to_be_named)
    unless peer_review_cycle
      peer_review_cycle = which_peer_review_cycle(current_user)
    end

    unless peer_review_cycle.try(:anonymise)
      return user_to_be_named.name
    end

    if current_user == self.user # as in, you're the user who created the assignment
      if self.permitted_users.include?(user_to_be_named)
        return "Anonymous Reviewer"
      end
    elsif (self.permitted_users - self.conveners).include?(current_user)
      if self.user == user_to_be_named
        return "Anonymous Submitter"
      end
    end
    return "#{user_to_be_named.name} (u#{user_to_be_named.uni_id})"
  end
end