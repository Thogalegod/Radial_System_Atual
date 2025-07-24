class AddFieldsToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :document_type, :string
    add_column :clients, :document_number, :string
    add_column :clients, :zip_code, :string
    add_column :clients, :state_registration, :string
  end
end
