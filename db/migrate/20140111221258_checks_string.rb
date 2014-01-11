class ChecksString < ActiveRecord::Migration
  def change
    add_column :assignments, :behaviour_on_submission, :string
  end
end
