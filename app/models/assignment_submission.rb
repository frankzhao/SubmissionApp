require "zip"

class AssignmentSubmission < ActiveRecord::Base
  include CheckingRules

  def self.group_by_day(field)
    AssignmentSubmission.group("CAST(assignment_submissions.#{field} AS DATE)")
  end

  attr_accessible :assignment_id, :body, :user_id

  belongs_to :assignment
  belongs_to :user

  has_many :comments, :dependent => :destroy
  has_many :marks, :through => :comments, :source => :marks
  has_many :peer_marks, :through => :comments, :source => :peer_marks

  has_many :submission_permissions, :dependent => :destroy

  has_many :permitted_users, :through => :submission_permissions,
                             :source => :user

  has_one :group_type, :through => :assignment, :source => :group_type
  has_many :courses, :through => :group_type, :source => :courses
  has_many :conveners, :through => :courses, :source => :convener

  validates :assignment_id, :user_id, :presence => true

  def self.uncommented(user)
    where(<<-SQL, user.id)
      (SELECT COUNT(*)
      FROM comments
      WHERE comments.assignment_submission_id = assignment_submissions.id
      AND comments.user_id = ?) = 0
    SQL
  end

  def self.where_user_is(user)
    where(:user_id => user.id)
  end

  def self.where_assignment_is(assignment)
    where(:assignment_id => assignment.id)
  end

  def self.finalized
    where(:is_finalized => true)
  end

  def group
    #TODO: this is probably inefficient. Rewrite it properly.
    self.user.student_groups.each do |group|
      if group.group_type == self.assignment.group_type
        return group
      end
    end
    return nil
  end

  # TODO: remove the n+1 shit
  def relationship_to_user(user)
    if user == self.user
      return :creator
    elsif (assignment.courses.map(&:staff).flatten +
                        assignment.courses.map(&:convener)).include?(user) ||
                            user.is_admin
      return :staff
    elsif self.which_peer_review_cycle(user)
      return :peer
    end
  end

  # This is all the people who are permitted to see the assignment.
  # TODO: make it so that the assignment has a setting to let all
  # staff for the course see all the assignments.
  # Also, faster, obviously
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
    self.assignment.path + "/#{self.id}_#{datetime}"
  end

  def zip_path
    self.file_path+".zip"
  end

  def upload=(whatever)
    @upload = whatever
  end

  def add_permission(user, cycle_id)
    SubmissionPermission.create!(:user_id => user.id,
                                 :assignment_submission_id => self.id,
                                 :peer_review_cycle_id => cycle_id)
  end

  def permits?(user)
    !! self.relationship_to_user(user)
  end

  def context_name(user_to_be_named, current_user)
    peer_review_cycle = which_peer_review_cycle(user_to_be_named)
    unless peer_review_cycle
      peer_review_cycle = which_peer_review_cycle(current_user)
    end

    unless peer_review_cycle.try(:anonymise)
      return user_to_be_named.name
    end

    if current_user == self.user # as in, you're the user who created the assignment
      if self.permitted_users.include?(user_to_be_named)
        return "Anonymous Reviewer"
      end
    elsif (self.permitted_users - self.conveners).include?(current_user)
      if self.user == user_to_be_named
        return "Anonymous Submitter"
      end
    end
    return "#{user_to_be_named.name} (u#{user_to_be_named.uni_id})"
  end

  def zip_contents
    zip_contents = {}
    Zip::File.open(self.zip_path) do |zipfile|
      names = zipfile.map{|e| e.name}
             .select{|x| x[0..5]!= "__MACO" }

      filetypes_to_show = self.assignment.filetypes_to_show.try(:split," ")

      if filetypes_to_show && filetypes_to_show.length > 0
        names.select! { |x| filetypes_to_show.any? {|y| tail_match?(x,y)}}
      end

      names.each do |name|
        begin
          zip_contents[name] = zipfile.read(name) if zipfile.read(name)
        rescue NoMethodError
        end
      end
    end

    zip_contents
  end

  def tail_match?(str1, str2)
    str1[-str2.length..-1] == str2
  end

  def receive_submission
    self.save_locally

    unless self.assignment.behavior_on_submission.empty?
      behavior_on_submission = JSON.parse(self.assignment.behavior_on_submission)

      behavior_on_submission.each do |command, args|
        self.interpret(command, args)
      end
    end
  end

  def finalize!
    logger.info "finalizing assignment submission #{id}"
    return if self.is_finalized
    self.is_finalized = true
    self.assignment.peer_review_cycles.each do |cycle|
      cycle.receive_submission(self)
    end
    self.save!
  end

  def add_anonymous_comment(body)
    Comment.create!(:body => body, :assignment_submission_id => self.id)
  end

  def top_level_comments
    self.comments.where(:parent_id => nil)
  end


  # If a user has access to a submission through two seperate cycles, the
  # latter one controls the conditions of viewing.
  # This shouldn't happen though.
  def which_peer_review_cycle(user)
    permission = self.submission_permissions.where(:user_id => user.id)
                               .order('created_at DESC')
                               .first

    if permission.try(:peer_review_cycle).try(:activated)
      permission.peer_review_cycle
    end
  end

  def commented_on_by_user?(user)
    ! self.comments.select { |c| c.user == user }
                   .empty?
  end

  def pretty_filename(user)
    user_name = self.context_name(self.user, user).gsub(" ","_")
    assignment_name = self.assignment.name.gsub(/ |-|:/, "_")
    user_name + "_" + assignment_name
  end
end
