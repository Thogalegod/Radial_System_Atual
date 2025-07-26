class FixEquipmentFeatureDataTypes < ActiveRecord::Migration[8.0]
  def up
    # Mapeamento de tipos antigos para novos
    type_mapping = {
      'text' => 'string',
      'number' => 'integer'
    }
    
    # Atualizar características com tipos incorretos
    type_mapping.each do |old_type, new_type|
      EquipmentFeature.where(data_type: old_type).update_all(data_type: new_type)
    end
    
    puts "✅ Tipos de dados corrigidos:"
    puts "   - 'text' → 'string'"
    puts "   - 'number' → 'integer'"
  end

  def down
    # Reverter as mudanças se necessário
    type_mapping = {
      'string' => 'text',
      'integer' => 'number'
    }
    
    type_mapping.each do |new_type, old_type|
      EquipmentFeature.where(data_type: new_type).update_all(data_type: old_type)
    end
  end
end
