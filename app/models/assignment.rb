class Assignment < ActiveRecord::Base
  attr_accessible :info, :name, :group_type, :group_type_id, :due_date,
                   :submission_format, :behavior_on_submission,
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
    Dir.mkdir(self.path) unless File.directory?(self.path)
  end

  #TODO: Add "marker" as a field here.
  def marks_csv
    marking_category_names = self.marking_categories.map(&:name).join(",")
    out = ["name,uni id,submission time,#{marking_category_names}"]
    self.students.each do |student|
      most_recent_submission = student.most_recent_submission(self)
      submission_time = most_recent_submission.created_at rescue ""
      marks = []
      self.marking_categories.each do |category|
        marks << category.mark_for_submission(most_recent_submission) rescue ""
      end
      out << "#{student.name},#{student.uni_id},#{submission_time},#{marks.join(",")}"
    end
    out.join("\n")
  end

  # Does the assignment have a due date in the past?
  # If it doesn't have a due date, it's never overdue.
  # If the due date isn't compulsary, it's never overdue
  # TODO: check this carefully.
  def already_due
    self.due_date && self.is_due_date_compulsary && self.due_date < Time.now
  end

  def add_marking_category!(hash)
    category = MarkingCategory.new(hash)
    category.assignment = self
    category.save!
  end

  def create_marking_scheme(scheme)
    scheme.each do |hash|
      self.add_marking_category!(hash)
    end
  end

  def replace_marking_scheme(scheme)
    self.marking_categories.each(&:destroy)
    create_marking_scheme(scheme)
  end

  def maximum_mark
    self.marking_categories.map{|x| x.maximum_mark}.sum
  end
end