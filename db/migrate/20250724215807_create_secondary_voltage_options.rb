class CreateSecondaryVoltageOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :secondary_voltage_options do |t|
      t.integer :value
      t.string :color

      t.timestamps
    end
  end
end
