class RemoveSourceFromMarkingScheme < ActiveRecord::Migration
  def change
    remove_column :marking_categories, :source
    add_column :peer_review_cycles, :maximum_mark, :integer
  end
end
