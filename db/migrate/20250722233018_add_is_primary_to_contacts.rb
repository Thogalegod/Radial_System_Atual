class AddIsPrimaryToContacts < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :is_primary, :boolean
  end
end
