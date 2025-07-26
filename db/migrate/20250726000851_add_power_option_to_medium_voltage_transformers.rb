class AddPowerOptionToMediumVoltageTransformers < ActiveRecord::Migration[8.0]
  def change
    add_reference :medium_voltage_transformers, :power_option, null: true, foreign_key: true
  end
end
