class RemoveDatesFromRentals < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:rentals)
      remove_column :rentals, :start_date
      remove_column :rentals, :end_date
    end
  end

  def down
    if table_exists?(:rentals)
      add_column :rentals, :start_date, :date
      add_column :rentals, :end_date, :date
    end
  end
end
