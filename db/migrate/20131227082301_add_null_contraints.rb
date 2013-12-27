class AddNullContraints < ActiveRecord::Migration
  def change
    change_column :assignment_submissions, :user_id, :integer, :null => false
  end
end
