class MarkingCategory < ActiveRecord::Base
  attr_accessible :assignment_id, :description, :maximum_mark, :name, :source

  validates :assignment, :description, :maximum_mark, :name,
            :presence => true

  belongs_to :assignment
  has_many :marks

  def relevant_to_user(submission, user)
    submission.staff.include? user
  end

  # implemented using my brand new design pattern where you use `and` to
  # simulate the Maybe monad.
  def mark_for_submission(submission)
    x = submission.marks.where(:marking_category_id => self.id).last and x.value
  end
end