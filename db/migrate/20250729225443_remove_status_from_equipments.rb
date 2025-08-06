class RemoveStatusFromEquipments < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:equipments)
      remove_column :equipments, :status
    end
  end

  def down
    if table_exists?(:equipments)
      add_column :equipments, :status, :string
    end
  end
end
