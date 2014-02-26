#Peer review cycles

There are two peer review cycles which can be created.

## Send to previous

This is the peer review cycle which roughly corresponds to "the submission is given to the student who submitted most recently." I will explain it by heavily commenting the code which implements it:

`  def send_to_previous(submission)
    user_submissions =  self.assignment
                            .submissions
                            .where("created_at > ?", self.activation_time)
                            .where(:user_id => submission.user)`

    return unless user_submissions.length == 1

    previous_users = self.assignment
                         .submissions
                         .where("created_at > ?", self.activation_time)
                         .order('created_at DESC')
                         .map { |s| s.user }

    previous_users.each do |previous_user|
      next if submission.user == previous_user
      if self.permitted_submissions_for_user(previous_user).empty?
        submission.add_permission(previous_user, self.id)
        return
      end
    end

    submission.add_permission(assignment.conveners.first, self.id)
  end