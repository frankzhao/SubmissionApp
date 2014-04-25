class Comment < ActiveRecord::Base
  attr_accessible :assignment_submission_id, :body, :user_id,
                  :peer_review_cycle_id, :has_file, :parent_id, :file_name,
                  :explicit_filepath, :custom_behavior_id

  belongs_to :assignment_submission
  delegate :assignment, :to => :assignment_submission

  belongs_to :user
  belongs_to :custom_behavior

  belongs_to :peer_review_cycle

  belongs_to :parent, :class_name => "Comment",
                      :foreign_key => :parent_id

  has_many :marks

  has_one :peer_mark

  has_many :children, :class_name => "Comment",
                      :foreign_key => :parent_id,
                      :primary_key => :id

  has_many :notifications, :as => :notable, :dependent => :destroy

  after_save :friendlify_filename, :send_notifications

  validates :assignment_submission_id, :body, :presence => true

  def self.where_not_automated
    where("comments.user_id IS NOT NULL")
  end

  def self.create_with_file_and_submission_id(file_path, submission_id)
    Comment.create(:explicit_filepath => file_path,
                   :assignment_submission_id => submission_id,
                   :body => "Please find comments attached.")
  end

  def file_path
    self.explicit_filepath || (
    "#{Rails.root.to_s}/upload/comment_related_files/#{self.id}_#{self.file_name}")
  end

  def friendlify_filename
    if self.file_name
      self.file_name = friendly_filename(self.file_name)
    end
  end

  def friendly_filename(filename)
    filename
  end

  def save_data(data)
    File.open(self.file_path, 'wb') do |f|
      f.write(data)
    end
  end

  def send_notifications
    if self.assignment_submission.assignment.visible_comments
      Notification.create!(:user_id => self.assignment_submission.user_id,
                           :notable_id => self.id,
                           :notable_type => "Comment")

      if self.parent
        Notification.create!(:user_id => self.parent.user_id,
                             :notable_id => self.id,
                             :notable_type => "Comment")
      end
    end
  end
end
