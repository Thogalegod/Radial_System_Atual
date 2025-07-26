class Equipment < ApplicationRecord
  self.table_name = 'equipments'
  
  # Configuração para rotas
  def self.model_name
    ActiveModel::Name.new(self, nil, 'Equipment')
  end
  # Relacionamentos
  belongs_to :equipment_type
  has_many :equipment_values, dependent: :destroy, foreign_key: 'equipments_id'
  has_many :equipment_features, through: :equipment_type

  # Validações
  validates :serial_number, presence: true, uniqueness: true, length: { minimum: 3, maximum: 100 }
  validates :equipment_type, presence: true
  validates :status, inclusion: { in: %w[active inactive maintenance retired] }
  validates :location, length: { maximum: 200 }
  validates :manufacturer, length: { maximum: 100 }
  validates :model, length: { maximum: 100 }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :maintenance, -> { where(status: 'maintenance') }
  scope :retired, -> { where(status: 'retired') }
  scope :with_notes, -> { where.not(notes: [nil, '']) }
  scope :without_notes, -> { where(notes: [nil, '']) }
  scope :by_type, ->(type_id) { where(equipment_type_id: type_id) }
  scope :by_location, ->(location) { where(location: location) }
  scope :by_manufacturer, ->(manufacturer) { where(manufacturer: manufacturer) }
  scope :ordered_by_serial, -> { order(:serial_number) }
  scope :ordered_by_created, -> { order(:created_at) }
  scope :ordered_by_updated, -> { order(:updated_at) }
  scope :with_feature_values, -> { includes(:equipment_values, :equipment_features) }
  scope :with_type, -> { includes(:equipment_type) }

  # Callbacks
  before_validation :set_default_status, on: :create

  # Métodos
  def display_name
    "#{equipment_type.name} #{serial_number}"
  end

  def status_display
    case status
    when 'active' then 'Ativo'
    when 'inactive' then 'Inativo'
    when 'maintenance' then 'Manutenção'
    when 'retired' then 'Aposentado'
    else status
    end
  end

  def status_color
    case status
    when 'active' then '#10B981'      # Green
    when 'inactive' then '#6B7280'    # Gray
    when 'maintenance' then '#F59E0B'  # Yellow
    when 'retired' then '#EF4444'     # Red
    else '#6B7280'
    end
  end

  def status_icon
    case status
    when 'active' then 'fas fa-check-circle'
    when 'inactive' then 'fas fa-pause-circle'
    when 'maintenance' then 'fas fa-tools'
    when 'retired' then 'fas fa-times-circle'
    else 'fas fa-question-circle'
    end
  end

  def feature_value(feature_name)
    feature = equipment_features.find_by(name: feature_name)
    return nil unless feature

    value_record = equipment_values.find_by(equipment_feature: feature)
    value_record&.value
  end

  def set_feature_value(feature_name, value, color = nil)
    feature = equipment_features.find_by(name: feature_name)
    return false unless feature

    value_record = equipment_values.find_or_initialize_by(equipment_feature: feature)
    value_record.value = value
    value_record.color = color if color.present?
    value_record.save
  end

  def feature_values
    equipment_values.includes(:equipment_feature).index_by { |v| v.equipment_feature.name }
  end

  def has_feature?(feature_name)
    equipment_features.exists?(name: feature_name)
  end

  def required_features_completed?
    required_features = equipment_features.where(required: true)
    required_features.all? do |feature|
      equipment_values.exists?(equipment_feature: feature, value: [nil, ''])
    end
  end

  def maintenance_due?
    return false unless next_maintenance_date
    next_maintenance_date <= Date.current
  end

  def maintenance_overdue?
    return false unless next_maintenance_date
    next_maintenance_date < Date.current
  end

  def age_in_days
    return nil unless installation_date
    (Date.current - installation_date).to_i
  end

  def age_in_years
    return nil unless installation_date
    ((Date.current - installation_date) / 365.25).to_i
  end

  private

  def set_default_status
    self.status = 'active' if status.blank?
  end
end 