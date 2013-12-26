class AssignmentSubmission < ActiveRecord::Base
  attr_accessible :assignment_id, :body, :user_id

  belongs_to :assignment
  belongs_to :user

  validates :assignment_id, :user_id, :presence => true

  def permits?(user)
    p [self.user ,
                        assignment.courses.map(&:staff).flatten ,
                        assignment.courses.map(&:convenor)]
    permitted_people = (self.user +
                        assignment.courses.map(&:staff).flatten +
                        assignment.courses.map(&:convenors))

    permitted_people.include?(user)
  end

end
