class User < ActiveRecord::Base
  attr_accessible :name, :session_token, :uni_id

  has_many :student_enrollments
  has_many :student_courses, :through => :student_enrollments

  has_many :staff_enrollments
  has_many :staffed_courses, :through => :staff_enrollments

  before_validation :reset_session_token, :on => :create

  validates :name, :session_token, :uni_id, :presence => true

  def reset_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end

  def reset_session_token!
    reset_session_token
    self.save!
  end
end
