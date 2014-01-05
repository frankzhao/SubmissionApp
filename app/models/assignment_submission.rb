require 'zip'

class AssignmentSubmission < ActiveRecord::Base
  attr_accessible :assignment_id, :body, :user_id

  belongs_to :assignment
  belongs_to :user

  after_save :save_locally

  has_many :comments

  has_one :group_type, :through => :assignment, :source => :group_type

  validates :assignment_id, :user_id, :presence => true

  def permits?(user)
    permitted_people = ([self.user] +
                        assignment.courses.map(&:staff).flatten +
                        assignment.courses.map(&:convenor))

    permitted_people.include?(user)
  end

  def group
    #TODO: this is horribly inefficient. Rewrite it properly.
    self.user.student_groups.each do |group|
      if group.group_type == self.assignment.group_type
        return group
      end
    end
  end

  def mark
    comments.map { |comment| comment.mark }.select{ |x| x }.last
  end

  # This is all the people who are permitted to see the assignment.
  # TODO: make it so that the assignment has a setting to let all
  # staff for the course see all the assignments.
  def staff
    group.staff + group.group_type.courses.map(&:convenor)
  end

  def url
    assignment_assignment_submission_url(
                        self.assignment_id, self.id)
  end

  def save_locally
    if self.assignment.submission_format == "plaintext"
      name = self.user.name.gsub(" ","_")
      filepath = "upload/#{self.assignment.name}_#{name}_#{self.id}.txt"
      File.open(filepath, 'w') do |f|
        f.write(self.body)
      end
    end
  end

  def save_data(data)
    name = self.user.name.gsub(" ","_")
    filepath = "upload/#{self.assignment.name}_#{name}_#{self.id}.zip"
    File.open(filepath, 'wb') do |f|
      f.write(self.upload)
    end
  end
end
