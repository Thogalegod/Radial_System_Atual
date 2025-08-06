class DropRentalsTable < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:rentals)
      # Remover foreign keys primeiro
      if foreign_key_exists?(:rental_billing_periods, :rental)
        remove_foreign_key :rental_billing_periods, :rental
      end
      
      # Usar drop_table do Rails em vez de execute SQL
      drop_table :rentals
    end
  end

  def down
    # Recriar a tabela rentals se necessário
    create_table :rentals do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :status
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
