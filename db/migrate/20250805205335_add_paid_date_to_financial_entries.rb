class AddPaidDateToFinancialEntries < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:financial_entries)
      add_column :financial_entries, :paid_date, :date
    end
  end

  def down
    if table_exists?(:financial_entries)
      remove_column :financial_entries, :paid_date
    end
  end
end
