class RenameSecondaryVoltageOptionIdToBtOptionIdInMediumVoltageTransformers < ActiveRecord::Migration[8.0]
  def change
    rename_column :medium_voltage_transformers, :secondary_voltage_option_id, :bt_option_id
  end
end
