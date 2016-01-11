class CreateSentLists < ActiveRecord::Migration
  def change
    create_table :sent_lists do |t|
    	t.string :department
    	t.string :course_number
      t.timestamps null: false
    end
  end
end
