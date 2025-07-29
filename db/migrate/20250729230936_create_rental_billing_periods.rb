class CreateRentalBillingPeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :rental_billing_periods do |t|
      t.references :rental, null: false, foreign_key: true
      t.string :name
      t.date :start_date
      t.date :end_date
      t.decimal :amount

      t.timestamps
    end
  end
end
