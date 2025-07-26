class CreatePowerOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :power_options do |t|
      t.integer :value
      t.string :color

      t.timestamps
    end
  end
end
