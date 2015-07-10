class AddTravelsTextDate < ActiveRecord::Migration
  def up
    add_column :travels, :date_str, :string
    Travel.all.each do  |t|
      t.update_columns(date_str: t.created_at.strftime('%Y%m%d') )
    end
    add_index :travels, :date_str
    change_column :travels, :date_str, :string, null: false
  end

  def down
    remove_column :travels, :date_str
  end
end
