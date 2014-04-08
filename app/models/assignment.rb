class Assignment < ActiveRecord::Base
  attr_accessible :info, :name, :group_type, :group_type_id, :due_date,
                   :submission_format, :behavior_on_submission,
                   :is_due_date_compulsary, :filepath_regex,
                   :is_visible, :submission_instructions, :visible_comments

  belongs_to :group_type
  has_many :groups, :through => :group_type, :source => :groups

  has_many :submissions, :class_name => "AssignmentSubmission"
  has_many :students_who_have_submitted, :through => :submissions, :source => :user
  has_many :submission_permissions, :through => :submissions,
                                    :source => :submission_permissions,
                                    :dependent => :destroy

  has_many :courses, :through => :group_type, :source => :courses
  has_many :conveners, :through => :courses, :source => :convener

  has_many :students, :through => :groups, :source => :students
  has_many :staff, :through => :groups, :source => :staff

  validates :info, :name, :group_type_id, :submission_format,
           :presence => true

  validate :name_is_acceptable
  validate :behavior_on_submission_is_json

  has_many :marking_categories, :dependent => :destroy

  has_many :peer_review_cycles, :dependent => :destroy

  has_many :extensions

  after_create :make_directory, :send_notifications

  extend FriendlyId

  friendly_id :name, :use => :slugged

  def self.visible
    self.where(:is_visible => true)
  end

  def name_is_acceptable
    unless self.name.match /\A[a-zA-Z:_0-9 ]+\Z/
      self.errors[:name] << "The name must match this regex: /\A[a-zA-Z:0-9 ]+\Z/. " +
                       "That is to say, it may only have letters, numbers, colons and spaces."
    end
  end

  def behavior_on_submission_is_json
    return if self.behavior_on_submission == ""
    begin
      json = JSON.parse(self.behavior_on_submission)
    rescue JSON::ParserError => e
      self.errors[:behavior_on_submission] << "JSON parse error: #{e}"
    end
  end

  def relevant_submissions(user)
    case user.relationship_to_assignment(self)
    when :student
      self.submissions.find_by_user_id_and_assignment_id(user.id, self.id)

    # TODO: Use SQl.
    when :staff
      # user.staffed_groups.where(:group_type_id => self.group_type_id)
      #           .map{ |x| x.students }
      #           .flatten
      #           .map{ |x| x.most_recent_submission(self) }
      #           .select{ |x| x }
      self.submissions
    when :convener
      self.submissions
      # out = self.students.map{ |x| x.most_recent_submission(self) }
      #                    .select{ |x| x }
    end
  end

  def path
    "#{Rails.root.to_s}/upload/#{self.path_without_upload}"
  end

  def path_without_upload
    "#{self.id}"
  end

  def update_zip
    system("zip -r #{self.path}.zip #{self.path}/*")
  end

  def zip_path
    "#{self.path}.zip"
  end

  def make_directory
    Dir.mkdir(self.path) unless File.directory?(self.path)
  end

  #TODO: Add "marker" as a field here.
  def marks_csv
    marking_category_names = self.marking_categories.map(&:name)

    first_line = ["name", "uni id", "submission time"] + marking_category_names


    peer_review_cycles.each do |cycle|
      if cycle.maximum_mark
        first_line << "Peer review cycle id #{cycle.id}"
      end
    end

    out = [first_line.join(",")]

    self.students.each do |student|
      most_recent_submission = student.most_recent_submission(self)
      submission_time = most_recent_submission.created_at rescue ""
      marks = []
      self.marking_categories.each do |category|
        marks << category.mark_for_submission(most_recent_submission) rescue ""
      end
      peer_review_cycles.each do |cycle|
        if cycle.maximum_mark
          marks << cycle.mark_for_submission(most_recent_submission) rescue ""
        end
      end
      out << "#{student.name},#{student.uni_id},#{submission_time},#{marks.join(",")}"
    end
    out.join("\n")
  end

  # Does the assignment have a due date in the past?
  # If it doesn't have a due date, it's never overdue.
  # If the due date isn't compulsary, it's never overdue
  # If the user has an extension, we use that date instead.
  def already_due(user)
    extension = Extension.find_by_user_id_and_assignment_id(user.id, self.id)
    if extension
      return extension.due_date < Time.zone.now
    end

    self.due_date && self.is_due_date_compulsary && self.due_date < Time.zone.now
  end

  def add_marking_category!(hash)
    category = MarkingCategory.new(hash)
    category.assignment_id = self.id
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

  def disable_submitting_until_comment(user)
    self.peer_review_cycles.any? { | cycle | cycle.disable_submissions(user) }
  end

  def conveners_and_staff
    self.conveners + self.staff
  end

  def send_notifications
    Notification.create!((self.students + self.staff).map do |u|
      {:user_id => u.id, :notable_id => self.id, :notable_type => "Assignment"}
    end)
  end
end