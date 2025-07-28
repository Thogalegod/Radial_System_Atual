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
  
  # Active Storage para fotos
  has_many_attached :photos

  # Validações
  validates :serial_number, presence: true, uniqueness: true, length: { minimum: 3, maximum: 100 }
  validates :equipment_type, presence: true
  validates :status, inclusion: { in: %w[em_estoque vendido alugado] }
  validates :location, inclusion: { in: %w[GP123 GP140 Escritório Eduardo\ Super\ Trafo Estrada\ Tronco], allow_blank: true }
  validates :bandeira, inclusion: { in: %w[Verde Amarelo Vermelho Preto Azul Verde/Amarelo], allow_blank: true }
  validates :acquisition_price, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  
  # Validação customizada para prevenir mudança do tipo de equipamento
  validate :equipment_type_cannot_be_changed, on: :update

  # Scopes
  scope :em_estoque, -> { where(status: 'em_estoque') }
  scope :vendido, -> { where(status: 'vendido') }
  scope :alugado, -> { where(status: 'alugado') }
  scope :with_notes, -> { where.not(notes: [nil, '']) }
  scope :without_notes, -> { where(notes: [nil, '']) }
  scope :by_type, ->(type_id) { where(equipment_type_id: type_id) }
  scope :by_location, ->(location) { where(location: location) }
  scope :by_bandeira, ->(bandeira) { where(bandeira: bandeira) }
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
    when 'em_estoque' then 'Em Estoque'
    when 'vendido' then 'Vendido'
    when 'alugado' then 'Alugado'
    else status
    end
  end

  def status_color
    case status
    when 'em_estoque' then '#10B981'  # Green
    when 'vendido' then '#EF4444'     # Red
    when 'alugado' then '#3B82F6'     # Blue
    else '#6B7280'
    end
  end

  def status_icon
    case status
    when 'em_estoque' then 'fas fa-box'
    when 'vendido' then 'fas fa-shopping-cart'
    when 'alugado' then 'fas fa-handshake'
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

  def age_in_days
    return nil unless acquisition_date
    (Date.current - acquisition_date).to_i
  end

  def age_in_years
    return nil unless acquisition_date
    ((Date.current - acquisition_date) / 365.25).to_i
  end

  def formatted_acquisition_price
    return nil unless acquisition_price
    "R$ #{acquisition_price.to_f.round(2).to_s.gsub('.', ',')}"
  end

  def bandeira_color
    case bandeira
    when 'Verde' then '#10B981'
    when 'Amarelo' then '#F59E0B'
    when 'Vermelho' then '#EF4444'
    when 'Preto' then '#1F2937'
    when 'Azul' then '#3B82F6'
    when 'Verde/Amarelo' then '#84CC16'
    else '#6B7280'
    end
  end

  private

  def set_default_status
    self.status = 'em_estoque' if status.blank?
  end
  
  private
  
  def equipment_type_cannot_be_changed
    if equipment_type_id_changed?
      errors.add(:equipment_type_id, "não pode ser alterado após a criação do equipamento")
    end
  end
end 