class AddDueDateCompulsaryness < ActiveRecord::Migration
  def change
    add_column :assignments, :is_due_date_compulsary, :boolean, :default => :false
  end
end
