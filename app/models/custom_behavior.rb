class CustomBehavior < ActiveRecord::Base
  attr_accessible :name, :details

  validates :name, :assignment_id, :presence => true

  belongs_to :assignment
end
