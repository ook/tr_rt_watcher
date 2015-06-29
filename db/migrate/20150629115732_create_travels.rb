class CreateTravels < ActiveRecord::Migration
  def change
    create_table :travels do |t|
      t.dateime :appear_at
      t.json :times
      t.string :num
      t.string :term
      t.string :mission
      t.string :from

      t.timestamps null: false
    end
  end
end
