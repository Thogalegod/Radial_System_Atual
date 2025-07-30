class AddClientOrderAndObservationsToRentalBillingPeriods < ActiveRecord::Migration[8.0]
  def change
    add_column :rental_billing_periods, :client_order, :string
    add_column :rental_billing_periods, :observations, :text
  end
end
