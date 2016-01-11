class AddEmailToSentLists < ActiveRecord::Migration
  def change
  	add_column :sent_lists, :email, :string
  	add_index :sent_lists, :email
  end
end
