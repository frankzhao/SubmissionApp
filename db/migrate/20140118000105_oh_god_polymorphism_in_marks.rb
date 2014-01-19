class OhGodPolymorphismInMarks < ActiveRecord::Migration
  def change
    remove_column :marks, :marking_category_id
    add_column :marks, :mark_provider_id, :integer, :null => false
    add_column :marks, :mark_provider_type, :string, :null => false
  end
end
