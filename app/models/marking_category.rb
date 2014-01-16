class MarkingCategory < ActiveRecord::Base
  attr_accessible :assignment_id, :description, :maximum_mark, :name, :source

  validates :assignment_id, :description, :maximum_mark, :name,
            :presence => true

  belongs_to :assignment
  has_many :marks
end
