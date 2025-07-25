class RenameSecondaryVoltageOptionToBtOption < ActiveRecord::Migration[8.0]
  def change
    rename_table :secondary_voltage_options, :bt_options
  end
end
