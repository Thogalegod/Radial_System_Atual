class AddMissingFieldsToEquipment < ActiveRecord::Migration[8.0]
  def change
    add_column :equipment, :power, :string
    add_column :equipment, :voltage, :string
  end
end
