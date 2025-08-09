class BackfillClientInFinancialEntries < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    say_with_time "Backfilling client_id for financial_entries" do
      execute <<-SQL.squish
        UPDATE financial_entries fe
        SET client_id = r.client_id
        FROM rental_billing_periods rbp
        INNER JOIN rentals r ON r.id = rbp.rental_id
        WHERE fe.reference_type = 'RentalBillingPeriod'
          AND fe.reference_id = rbp.id
          AND fe.client_id IS NULL
      SQL
    end
  end

  def down
    # Não reverte
  end
end


