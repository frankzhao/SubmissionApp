class MarkingCategory < ActiveRecord::Base
  attr_accessible :assignment_id, :description, :maximum_mark, :name, :source

  validates :assignment_id, :description, :maximum_mark, :name,
            :presence => true

  validates :maximum_mark, :numericality => true

  belongs_to :assignment
  has_many :marks, :dependent => :destroy

  def relevant_to_user(submission, user)
    submission.staff.include? user
  end

  def mark_for_submission(submission)
    submission.marks.where(:marking_category_id => self.id).last.try(:value)
  end
end