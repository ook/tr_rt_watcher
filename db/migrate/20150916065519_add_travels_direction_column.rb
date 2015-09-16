class AddTravelsDirectionColumn < ActiveRecord::Migration
  def change
    add_column :travels, :direction, :boolean
  end
end
