class AddCompanyToFinancialEntries < ActiveRecord::Migration[8.0]
  def up
    add_column :financial_entries, :company, :string
    add_index :financial_entries, :company
  end

  def down
    remove_index :financial_entries, :company if index_exists?(:financial_entries, :company)
    remove_column :financial_entries, :company if column_exists?(:financial_entries, :company)
  end
end




