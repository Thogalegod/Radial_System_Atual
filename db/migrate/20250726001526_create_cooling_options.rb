class CreateCoolingOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :cooling_options do |t|
      t.string :value
      t.string :color

      t.timestamps
    end
  end
end
