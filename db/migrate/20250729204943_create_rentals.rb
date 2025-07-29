class CreateRentals < ActiveRecord::Migration[8.0]
  def change
    create_table :rentals do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :status
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
