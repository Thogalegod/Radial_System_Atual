class AddClientOrderAndObservationsToRentalBillingPeriods < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:rental_billing_periods)
      add_column :rental_billing_periods, :client_order, :string
      add_column :rental_billing_periods, :observations, :text
    end
  end

  def down
    if table_exists?(:rental_billing_periods)
      remove_column :rental_billing_periods, :client_order
      remove_column :rental_billing_periods, :observations
    end
  end
end
