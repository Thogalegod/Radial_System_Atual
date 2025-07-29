class RemoveDatesFromRentals < ActiveRecord::Migration[8.0]
  def change
    remove_column :rentals, :start_date, :date
    remove_column :rentals, :end_date, :date
  end
end
