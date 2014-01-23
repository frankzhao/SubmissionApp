class Comment < ActiveRecord::Base
  #TODO: nested comments

  attr_accessible :assignment_submission_id, :body, :user_id,
                  :peer_review_cycle_id, :has_file, :parent_id, :file_name

  belongs_to :assignment_submission
  delegate :assignment, :to => :assignment_submission

  belongs_to :user
  belongs_to :peer_review_cycle

  has_many :marks

  has_one :peer_mark

  has_many :children, :class_name => "Comment",
                      :foreign_key => :parent_id,
                      :primary_key => :id

  before_save :friendlify_filename

  validates :assignment_submission_id, :body, :presence => true

  def file_path
    "upload/comment_related_files/#{self.id}_#{self.file_name}"
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


end
