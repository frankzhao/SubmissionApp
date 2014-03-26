class Extension < ActiveRecord::Base
  attr_accessible :assignment_id, :due_date, :user_id

  belongs_to :user
  belongs_to :assignment

  validates :user_id, :assignment_id, :presence => true
end
