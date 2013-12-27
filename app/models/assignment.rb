class Assignment < ActiveRecord::Base
  attr_accessible :info, :name, :group_type

  belongs_to :group_type
  has_many :submissions, :class_name => "AssignmentSubmission"

  has_many :courses, :through => :group_type, :source => :courses

  def relevant_submissions(user)
    case user.relationship_to_assignment(self)
    when :student
      submissions.find_by_user_id_and_assignment_id(user.id, self.id)
    when :staff
      user.staffed_groups.where(:group_type_id => self.group_type_id)
                         .map{ |x| x.submissions(self) }.flatten
    when :convenor
      submissions
    end
  end

  def url
    assignment_url(self)
  end

end
