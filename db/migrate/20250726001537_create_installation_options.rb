class CreateInstallationOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :installation_options do |t|
      t.string :value
      t.string :color

      t.timestamps
    end
  end
end
