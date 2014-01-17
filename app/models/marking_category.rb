class MarkingCategory < ActiveRecord::Base
  attr_accessible :assignment_id, :description, :maximum_mark, :name, :source

  validates :assignment_id, :description, :maximum_mark, :name,
            :presence => true

  belongs_to :assignment
  has_many :marks

  def relevant_to_user(submission, user)
    submission.staff.include? user
  end

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