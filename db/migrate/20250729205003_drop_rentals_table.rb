class DropRentalsTable < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:rentals)
      execute "DROP TABLE rentals CASCADE"
    end
  end

  def down
    # Não fazemos nada no down pois queremos recriar a tabela
  end
end
