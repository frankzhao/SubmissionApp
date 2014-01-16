class RemoveCompulsarySourceInMarkingScheme < ActiveRecord::Migration
  def change
    change_column :marking_categories, :source, :string, :null => true
  end
end
