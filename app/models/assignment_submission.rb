require "zip"

class AssignmentSubmission < ActiveRecord::Base
  include CheckingRules
  include SubmissionFileStuffHelper
  include PeerReviewHelper

  attr_accessible :assignment_id, :body, :user_id

  belongs_to :assignment
  belongs_to :user

  has_many :comments, :dependent => :destroy
  has_many :marks, :through => :comments, :source => :marks
  has_many :peer_marks, :through => :comments, :source => :peer_marks

  has_many :submission_permissions, :dependent => :destroy

  has_many :permitted_users, :through => :submission_permissions,
                             :source => :user

  has_many :submission_files

  has_one :group_type, :through => :assignment, :source => :group_type
  has_many :courses, :through => :group_type, :source => :courses
  has_many :conveners, :through => :courses, :source => :convener

  validates :assignment_id, :user_id, :presence => true

  def self.group_by_day(field)
    AssignmentSubmission.group("CAST(assignment_submissions.#{field} AS DATE)")
  end

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

  # TODO: remove the n+1 query
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
  # staff for the course see all the submissions.
  # Also, faster, obviously
  def staff
    group.staff + group.group_type.courses.map(&:convener)
  end

  def permits?(user)
    !! self.relationship_to_user(user)
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

  def receive_submission
    self.save_locally
    self.assignment.custom_behaviors.each do |behavior|
      behavior.receive_submission(self)
    end
  end
end
