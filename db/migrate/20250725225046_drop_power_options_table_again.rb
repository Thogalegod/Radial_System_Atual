class DropPowerOptionsTableAgain < ActiveRecord::Migration[8.0]
  def change
    drop_table :power_options, if_exists: true
  end
end
