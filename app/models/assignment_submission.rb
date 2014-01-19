require 'zip'

class AssignmentSubmission < ActiveRecord::Base
  include CheckingRules

  attr_accessible :assignment_id, :body, :user_id

  belongs_to :assignment
  belongs_to :user

  after_save :save_locally, :do_custom_things

  has_many :comments
  has_many :marks, :through => :comments, :source => :marks

  has_many :submission_permissions

  has_many :permitted_users, :through => :submission_permissions,
                             :source => :user

  has_one :group_type, :through => :assignment, :source => :group_type

  validates :assignment_id, :user_id, :presence => true

  # TODO: rewrite with SQL
  def permits?(user)
    permitted_people = ([self.user] +
                        assignment.courses.map(&:staff).flatten +
                        assignment.courses.map(&:convener) +
                        self.permitted_users)

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

  # This is all the people who are permitted to see the assignment.
  # TODO: make it so that the assignment has a setting to let all
  # staff for the course see all the assignments.
  # Also, SQL, obviously
  def staff
    group.staff + group.group_type.courses.map(&:convener)
  end

  def url
    assignment_assignment_submission_url(
                        self.assignment_id, self.id)
  end

  def save_locally
    if self.assignment.submission_format == "plaintext"
      File.open(self.file_path+".txt", 'w') do |f|
        f.write(self.body)
      end
    end
  end


  def save_data(data)
    File.open(self.zip_path, 'wb') do |f|
      f.write(data)
    end
  end

  def file_path
    name = self.user.name.gsub(" ","_")
    datetime = self.created_at.to_s.gsub(" ","_")
    self.assignment.path + "/#{name}_#{self.id}_#{datetime}"
  end

  def zip_path
    self.file_path+".zip"
  end

  def upload=(whatever)
    @upload = whatever
  end

  def add_permission(user)
    SubmissionPermission.create!(:user_id => user.id,
                                 :assignment_submission_id => self.id)
  end

  def context_name(user, current_user)
    if current_user == self.user
      if self.permitted_users.include?(user)
        return "Anonymous Reviewer"
      end
    elsif self.permitted_users.include?(current_user)
      if self.user == user
        return "Anonymous Submitter"
      end
    end
    return "#{user.name} (u#{user.uni_id})"
  end

  def zip_contents
    zip_contents = {}
    Zip::File.open(self.zip_path) do |zipfile|
        names = zipfile.map{|e| e.name}
               .select{|x| x[0..5]!= "__MACO" }
               .select{ |x| [".rb",".js",".hs"].any? {|y| tail_match?(x,y)}}

        names.each do |name|
          zip_contents[name] = zipfile.read(name)
        end
    end
    zip_contents
  end

  def tail_match?(str1, str2)
    str1[-str2.length..-1] == str2
  end

  def do_custom_things
    if self.assignment.behavior_on_submission.include? "check_compiling_haskell"
      self.check_compiling_haskell
    end
  end

  def add_anonymous_comment(body)
    Comment.create(:body => body, :assignment_submission_id => self.id)
  end

  def relationship_to_user(user)
    if user == self.user
      return :creator
    elsif (assignment.courses.map(&:staff).flatten +
                        assignment.courses.map(&:convener)).include?(user)
      return :staff
    elsif self.permitted_users.include? user
      return :peer
    end
  end

  # TODO: what happens if there's more than one peer review cycle which pairs
  # the same person and assignment?
  def which_peer_review_cycle(user)
    self.submission_permissions.where(:user_id => user.id).first.id
  end

end
