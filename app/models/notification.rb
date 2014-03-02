class Notification < ActiveRecord::Base
  attr_accessible :notable_id, :notable_type, :user_id
end
