class CustomBehavior < ActiveRecord::Base
  attr_accessible :name, :details

  belongs_to :assignment
end
