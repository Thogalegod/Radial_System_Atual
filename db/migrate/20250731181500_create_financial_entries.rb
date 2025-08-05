class CreateFinancialEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_entries do |t|
      t.string :description, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :due_date, null: false
      t.string :status, default: 'pending', null: false
      t.string :entry_type, null: false
      t.string :reference_type
      t.integer :reference_id
      t.text :notes

      t.timestamps
    end

    add_index :financial_entries, :status
    add_index :financial_entries, :entry_type
    add_index :financial_entries, :due_date
    add_index :financial_entries, [:reference_type, :reference_id]
  end
end
