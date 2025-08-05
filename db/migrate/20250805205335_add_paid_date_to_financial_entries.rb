class AddPaidDateToFinancialEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :financial_entries, :paid_date, :date
  end
end
