class AddUserIdToAlerts < ActiveRecord::Migration
  def change
  	add_column :alerts, :user_id, :integer
  	add_index :alerts, :user_id
  end
end
