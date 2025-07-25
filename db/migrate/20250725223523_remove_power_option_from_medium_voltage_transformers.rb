class RemovePowerOptionFromMediumVoltageTransformers < ActiveRecord::Migration[8.0]
  def change
    remove_reference :medium_voltage_transformers, :power_option, null: false, foreign_key: true
  end
end
