class RenameAradialToRadialInFinancialEntries < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE financial_entries
      SET company = 'Radial Equipamentos'
      WHERE company = 'Aradial Equipamentos';
    SQL
  end

  def down
    execute <<~SQL
      UPDATE financial_entries
      SET company = 'Aradial Equipamentos'
      WHERE company = 'Radial Equipamentos';
    SQL
  end
end


