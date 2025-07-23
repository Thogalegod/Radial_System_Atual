class SetDefaultIsPrimaryForContacts < ActiveRecord::Migration[8.0]
  def change
    change_column_default :contacts, :is_primary, from: nil, to: false
  end
end
