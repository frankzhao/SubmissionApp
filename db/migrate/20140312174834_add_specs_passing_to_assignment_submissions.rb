class AddSpecsPassingToAssignmentSubmissions < ActiveRecord::Migration
  def change
    add_column :assignment_submissions, :specs_passing, :integer
  end
end
