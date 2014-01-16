class MarkingCategory < ActiveRecord::Base
  attr_accessible :assignment_id, :description, :maximum_mark, :name, :source
end
