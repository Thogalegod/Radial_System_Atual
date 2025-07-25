class CreateMediumVoltageTransformers < ActiveRecord::Migration[8.0]
  def change
    create_table :medium_voltage_transformers do |t|
      t.string :serial_number
      t.string :location
      t.text :notes
      t.references :secondary_voltage_option, null: false, foreign_key: true

      t.timestamps
    end
  end
end
