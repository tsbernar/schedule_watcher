class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|

      t.timestamps null: false
    end
  end
end
