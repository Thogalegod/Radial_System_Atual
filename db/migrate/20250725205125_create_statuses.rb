class CreateStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :statuses do |t|
      t.string :value
      t.string :color

      t.timestamps
    end
  end
end
