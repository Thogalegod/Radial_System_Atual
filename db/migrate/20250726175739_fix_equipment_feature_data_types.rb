class FixEquipmentFeatureDataTypes < ActiveRecord::Migration[8.0]
  def up
    # Usar SQL direto em vez de modelos Rails durante migração
    execute <<-SQL
      UPDATE equipment_features 
      SET data_type = 'string' 
      WHERE data_type = 'text'
    SQL
    
    execute <<-SQL
      UPDATE equipment_features 
      SET data_type = 'integer' 
      WHERE data_type = 'number'
    SQL
    
    puts "✅ Tipos de dados corrigidos:"
    puts "   - 'text' → 'string'"
    puts "   - 'number' → 'integer'"
  end

  def down
    # Reverter as mudanças
    execute <<-SQL
      UPDATE equipment_features 
      SET data_type = 'text' 
      WHERE data_type = 'string'
    SQL
    
    execute <<-SQL
      UPDATE equipment_features 
      SET data_type = 'number' 
      WHERE data_type = 'integer'
    SQL
  end
end
