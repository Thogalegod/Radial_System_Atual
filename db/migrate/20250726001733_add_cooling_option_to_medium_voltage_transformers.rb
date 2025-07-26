class AddCoolingOptionToMediumVoltageTransformers < ActiveRecord::Migration[8.0]
  def change
    add_reference :medium_voltage_transformers, :cooling_option, null: true, foreign_key: true
  end
end
