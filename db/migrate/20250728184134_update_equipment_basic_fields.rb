class UpdateEquipmentBasicFields < ActiveRecord::Migration[8.0]
  def change
    # Remover campos que não serão mais usados
    remove_column :equipments, :manufacturer, :string
    remove_column :equipments, :model, :string
    remove_column :equipments, :next_maintenance_date, :date
    
    # Renomear installation_date para acquisition_date
    rename_column :equipments, :installation_date, :acquisition_date
    
    # Adicionar novo campo de preço de aquisição (decimal para precisão monetária)
    add_column :equipments, :acquisition_price, :decimal, precision: 10, scale: 2
    
    # Adicionar campo bandeira como string (será usado como select)
    add_column :equipments, :bandeira, :string
    
    # Alterar location para ter opções específicas (será tratado como select)
    # O campo location permanece como string, mas terá opções predefinidas
  end
end
