class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
  		t.string :department
  		t.string :course_number
      t.timestamps null: false
    end
  end
end
