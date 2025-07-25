class AddLocationAndStatusToMediumVoltageTransformers < ActiveRecord::Migration[8.0]
  def change
    add_reference :medium_voltage_transformers, :location, null: true, foreign_key: true
    add_reference :medium_voltage_transformers, :status, null: true, foreign_key: true
  end
end
