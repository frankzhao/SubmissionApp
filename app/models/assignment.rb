class Assignment < ActiveRecord::Base
  attr_accessible :info, :name, :group_type

  belongs_to :group_type
  has_many :groups, :through => :group_type, :source => :groups

  has_many :submissions, :class_name => "AssignmentSubmission"

  has_many :courses, :through => :group_type, :source => :courses

  has_many :students, :through => :groups, :source => :students
  has_many :staff, :through => :groups, :source => :staff

  def relevant_submissions(user)
    case user.relationship_to_assignment(self)
    when :student
      submissions.find_by_user_id_and_assignment_id(user.id, self.id)

    # TODO: Use SQl.
    when :staff
      user.staffed_groups.where(:group_type_id => self.group_type_id)
                .map{ |x| x.students }
                .flatten
                .map{ |x| x.most_recent_submission(self) }
                .select{ |x| x }
    when :convenor
      out = self.students.map{ |x| x.most_recent_submission(self) }
                         .select{ |x| x }
    end
  end

  def url
    assignment_url(self)
  end

end
