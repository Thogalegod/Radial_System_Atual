class AddClientToFinancialEntries < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:financial_entries, :client_id)
      add_reference :financial_entries, :client, null: true
    end

    unless index_exists?(:financial_entries, :client_id)
      add_index :financial_entries, :client_id
    end

    unless foreign_key_exists?(:financial_entries, :clients)
      add_foreign_key :financial_entries, :clients
    end
  end
end


