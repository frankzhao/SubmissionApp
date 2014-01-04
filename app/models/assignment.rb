class Assignment < ActiveRecord::Base
  attr_accessible :info, :name, :group_type, :due_date

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

  #TODO: Add "marker" as a field here.
  def marks_csv
    out = ["name,uni id,submission time,mark"]
    self.students.each do |student|
      most_recent_submission = student.most_recent_submission(self)
      submission_time = most_recent_submission.created_at rescue ""
      mark = most_recent_submission.mark || "not marked" rescue "not submitted"
      out << "#{student.name},#{student.uni_id},#{submission_time},#{mark}"
    end
    out.join("\n")
  end

end
