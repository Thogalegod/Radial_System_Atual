class CreateGenericEquipmentSystem < ActiveRecord::Migration[8.0]
  def change
    # Tabela de tipos de equipamento
    create_table :equipment_types do |t|
      t.string :name, null: false
      t.string :description
      t.string :icon_class, default: 'fas fa-cog' # Classe CSS para ícone
      t.string :primary_color, default: '#3B82F6' # Cor primária do tipo
      t.string :secondary_color, default: '#1E40AF' # Cor secundária
      t.string :accent_color, default: '#DBEAFE' # Cor de destaque
      t.boolean :active, default: true
      t.integer :sort_order, default: 0
      t.timestamps
    end

    add_index :equipment_types, :name, unique: true
    add_index :equipment_types, :active
    add_index :equipment_types, :sort_order

    # Tabela de equipamentos
    create_table :equipments do |t|
      t.string :serial_number, null: false
      t.references :equipment_type, null: false, foreign_key: true
      t.text :notes
      t.string :status, default: 'active' # active, inactive, maintenance, retired
      t.string :location
      t.string :manufacturer
      t.string :model
      t.date :installation_date
      t.date :last_maintenance_date
      t.date :next_maintenance_date
      t.timestamps
    end

    add_index :equipments, :serial_number, unique: true
    add_index :equipments, :status
    add_index :equipments, :location
    add_index :equipments, :manufacturer

    # Tabela de características dos equipamentos
    create_table :equipment_features do |t|
      t.references :equipment_type, null: false, foreign_key: true
      t.string :name, null: false
      t.string :data_type, null: false # string, integer, float, boolean, date, select
      t.string :unit # unidade de medida (V, kVA, etc.)
      t.text :description
      t.boolean :required, default: false
      t.boolean :searchable, default: true
      t.boolean :filterable, default: true
      t.boolean :sortable, default: true
      t.string :default_value
      t.text :options # JSON para campos select
      t.string :validation_rules # regex ou regras de validação
      t.string :display_format # formato de exibição
      t.string :color, default: '#6B7280' # cor da característica
      t.string :icon_class # ícone para a característica
      t.integer :sort_order, default: 0
      t.timestamps
    end

    add_index :equipment_features, [:equipment_type_id, :name], unique: true
    add_index :equipment_features, :data_type
    add_index :equipment_features, :required
    add_index :equipment_features, :searchable
    add_index :equipment_features, :filterable
    add_index :equipment_features, :sortable
    add_index :equipment_features, :sort_order

    # Tabela de opções para campos select
    create_table :equipment_feature_options do |t|
      t.references :equipment_feature, null: false, foreign_key: true
      t.string :value, null: false
      t.string :label
      t.string :color, default: '#6B7280'
      t.string :icon_class
      t.integer :sort_order, default: 0
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :equipment_feature_options, [:equipment_feature_id, :value], unique: true, name: 'index_feature_options_on_feature_and_value'
    add_index :equipment_feature_options, :active
    add_index :equipment_feature_options, :sort_order

    # Tabela de valores das características
    create_table :equipment_values do |t|
      t.references :equipments, null: false, foreign_key: true
      t.references :equipment_feature, null: false, foreign_key: true
      t.string :value
      t.string :color, default: '#6B7280' # cor do valor específico
      t.string :style_class # classe CSS adicional
      t.timestamps
    end

    add_index :equipment_values, [:equipments_id, :equipment_feature_id], unique: true, name: 'index_equipment_values_on_equipment_and_feature'
    add_index :equipment_values, :value
    add_index :equipment_values, :color
  end
end
