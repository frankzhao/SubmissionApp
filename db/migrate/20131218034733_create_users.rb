class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, :null => false
      t.integer :uni_id, :null => false  #TODO: check whether this is optional
      t.string :session_token, :null => false

      t.timestamps
    end
  end
end
