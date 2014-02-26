#Peer review cycles

There are two peer review cycles which can be created.

## Send to previous

This is the peer review cycle which roughly corresponds to "the submission is given to the student who submitted most recently." I will explain it by heavily commenting the code which implements it, which lives in `app/models/peer_review_cycles.rb`.

This function, `send_to_previous` is activated whenever a user submits to an assignment with a send-to-previous cycle activated. The first piece of logic looks at the assignment's submissions, filters them down to just those which were submitted after the cycle was activated, and which were submitted by this user.

```ruby
def send_to_previous(submission)
    user_submissions =  self.assignment
                            .submissions
                            .where("created_at > ?", self.activation_time)
                            .where(:user_id => submission.user)`
```

We only want to swap submissions if the user has exactly one previous submission--presumably, the one they just submitted, which triggered this method call.

```ruby
    return unless user_submissions.length == 1
```

This sets `previous_users` to the creators of previous submissions to this assignment which were submitted after the cycle was activated, ordered by when they were created.

```ruby
    previous_users = self.assignment
                         .submissions
                         .where("created_at > ?", self.activation_time)
                         .order('created_at DESC')
                         .map { |s| s.user }
```

Now, we start looping over those users, starting with the most recent submitter. If the user hasn't been assigned any submissions to view, then we add a permission for them to view this submission.

```ruby
    previous_users.each do |previous_user|
      if self.permitted_submissions_for_user(previous_user).empty?
        submission.add_permission(previous_user, self.id)
        return
      end
    end
```

If all of those students are occupied peer reviewing other assignments (eg if no other students have submitted yet), submit it to the convener of the course, who will be happy to look at the first submitted assignment.

```ruby
    submission.add_permission(assignment.conveners.first, self.id)
  end
```
