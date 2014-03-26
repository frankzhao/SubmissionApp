class Extension < ActiveRecord::Base
  attr_accessible :assignment_id, :due_time, :user_id
end
