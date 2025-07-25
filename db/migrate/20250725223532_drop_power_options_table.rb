class DropPowerOptionsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :power_options
  end
end
