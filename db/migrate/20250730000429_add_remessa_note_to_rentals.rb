class AddRemessaNoteToRentals < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:rentals)
      add_column :rentals, :remessa_note, :string
    end
  end

  def down
    if table_exists?(:rentals)
      remove_column :rentals, :remessa_note
    end
  end
end
