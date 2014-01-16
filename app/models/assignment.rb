class Assignment < ActiveRecord::Base
  attr_accessible :info, :name, :group_type, :group_type_id, :due_date,
                   :submission_format, :behavior_on_submission, :maximum_mark,
                   :is_due_date_compulsary

  belongs_to :group_type
  has_many :groups, :through => :group_type, :source => :groups

  has_many :submissions, :class_name => "AssignmentSubmission"
  has_many :students_who_have_submitted, :through => :submissions, :source => :user
  has_many :submission_permissions, :through => :submissions, :source => :submission_permissions

  has_many :courses, :through => :group_type, :source => :courses
  has_many :conveners, :through => :courses, :source => :convener

  has_many :students, :through => :groups, :source => :students
  has_many :staff, :through => :groups, :source => :staff

  validate :info, :name, :group_type_id, :due_date, :submission_format, :behavior_on_submission,
          :presence => true

  has_many :marking_categories

  after_create :make_directory

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
    when :convener
      out = self.students.map{ |x| x.most_recent_submission(self) }
                         .select{ |x| x }
    end
  end

  def path
    "upload/#{self.path_without_upload}"
  end

  def path_without_upload
    "#{self.id}_#{self.name}"
  end

  def update_zip
    system("cd upload && zip -r #{self.path_without_upload}.zip #{self.path_without_upload}")
  end

  def zip_path
    "#{self.path}.zip"
  end

  def make_directory
    puts "*"*100
    p `ls upload`
    Dir.mkdir(self.path) unless File.directory?(self.path)
    p `ls upload`
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

  def start_peer_review
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

  # Does the assignment have a due date in the past?
  # If it doesn't have a due date, it's never overdue.
  # If the due date isn't compulsary, it's never overdue
  def already_due
    p "#{self.name} !!! #{self.due_date} #{self.is_due_date_compulsary}"
    self.due_date && self.is_due_date_compulsary && self.due_date < Time.now
  end
end
