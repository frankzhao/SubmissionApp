class CreateCustomBehaviors < ActiveRecord::Migration
  def change
    create_table :custom_behaviors do |t|

      t.timestamps
    end
  end
end
