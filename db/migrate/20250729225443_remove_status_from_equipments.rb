class RemoveStatusFromEquipments < ActiveRecord::Migration[8.0]
  def change
    remove_column :equipments, :status, :string
  end
end
