class AddDefaultStatusToRentals < ActiveRecord::Migration[8.0]
  def up
    # Verificar se a tabela existe antes de modificar
    if table_exists?(:rentals)
      change_column_default :rentals, :status, 'ativo'
      
      # Atualizar registros existentes que têm status NULL
      execute <<-SQL
        UPDATE rentals 
        SET status = 'ativo' 
        WHERE status IS NULL
      SQL
    end
  end

  def down
    if table_exists?(:rentals)
      change_column_default :rentals, :status, nil
    end
  end
end
