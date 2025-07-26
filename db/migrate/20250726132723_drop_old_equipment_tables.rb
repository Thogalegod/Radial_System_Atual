class DropOldEquipmentTables < ActiveRecord::Migration[8.0]
  def up
    # Remover foreign keys primeiro
    remove_foreign_key :medium_voltage_transformers, :bt_options if foreign_key_exists?(:medium_voltage_transformers, :bt_options)
    remove_foreign_key :medium_voltage_transformers, :power_options if foreign_key_exists?(:medium_voltage_transformers, :power_options)
    remove_foreign_key :medium_voltage_transformers, :cooling_options if foreign_key_exists?(:medium_voltage_transformers, :cooling_options)
    remove_foreign_key :medium_voltage_transformers, :flag_options if foreign_key_exists?(:medium_voltage_transformers, :flag_options)
    remove_foreign_key :medium_voltage_transformers, :installation_options if foreign_key_exists?(:medium_voltage_transformers, :installation_options)
    remove_foreign_key :medium_voltage_transformers, :locations if foreign_key_exists?(:medium_voltage_transformers, :locations)
    remove_foreign_key :medium_voltage_transformers, :statuses if foreign_key_exists?(:medium_voltage_transformers, :statuses)

    # Deletar tabelas de equipamentos
    drop_table :medium_voltage_transformers if table_exists?(:medium_voltage_transformers)
    
    # Deletar tabelas de opções
    drop_table :bt_options if table_exists?(:bt_options)
    drop_table :power_options if table_exists?(:power_options)
    drop_table :cooling_options if table_exists?(:cooling_options)
    drop_table :flag_options if table_exists?(:flag_options)
    drop_table :installation_options if table_exists?(:installation_options)
    drop_table :locations if table_exists?(:locations)
    drop_table :statuses if table_exists?(:statuses)
  end

  def down
    # Recriar tabelas se necessário (não vamos usar isso, mas mantemos para compatibilidade)
    raise ActiveRecord::IrreversibleMigration
  end
end
