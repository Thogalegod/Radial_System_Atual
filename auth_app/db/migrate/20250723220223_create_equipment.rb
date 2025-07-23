class CreateEquipment < ActiveRecord::Migration[8.0]
  def change
    create_table :equipment do |t|
      t.string :number
      t.string :status
      t.string :power
      t.string :voltage
      t.string :location

      t.timestamps
    end
  end
end
