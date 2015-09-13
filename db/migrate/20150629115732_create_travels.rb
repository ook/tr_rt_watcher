class CreateTravels < ActiveRecord::Migration
  def change
    create_table :travels do |t|
      t.datetime :theorically_enter_at
      t.text   :times, array: true, default: []
      t.string :num, null: false
      t.string :term
      t.string :mission, null: false
      t.string :stop_id, null: false
      t.string :status
      t.string :ligne
      t.string :route
      t.string :date_str, null: false
      t.integer :stop_sequence, precision: 0, null: false

      t.timestamps null: false
    end
    add_index :travels, :date_str
  end
end
