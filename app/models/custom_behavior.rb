class CustomBehavior < ActiveRecord::Base
  attr_accessible :name, :details

  validates :name, :assignment_id, :presence => true

  belongs_to :assignment

  after_save :run_again

  has_many :comments, :dependent => :destroy

  include CheckingRules

  def behavior_on_submission_is_json
    return if self.details == ""
    begin
      json = JSON.parse(self.details)
    rescue JSON::ParserError => e
      self.errors[:details] << "JSON parse error: #{e}"
    end
  end

  def details_json
    return nil if self.details.nil? || self.details.empty?
    JSON.parse(self.details)
  end

  def receive_submission(submission)
    p "receiving submission: #{self} #{submission}"
    self.send(self.name, submission, self.details_json)
  end

  def run_again
    self.comments.delete_all

    self.assignment.submissions.each do |submission|
      self.receive_submission(submission)
    end
  end
end
