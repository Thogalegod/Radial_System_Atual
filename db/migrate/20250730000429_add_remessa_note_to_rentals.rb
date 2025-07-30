class AddRemessaNoteToRentals < ActiveRecord::Migration[8.0]
  def change
    add_column :rentals, :remessa_note, :string
  end
end
