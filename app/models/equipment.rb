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
  has_many :rental_equipments, dependent: :destroy
  has_many :rentals, through: :rental_equipments

  # Active Storage para fotos
  has_many_attached :photos

  # Validações
  validates :serial_number, presence: true, uniqueness: true, length: { minimum: 3, maximum: 100 }
  validates :equipment_type, presence: true
  validates :location, inclusion: { in: %w[GP123 GP140 Escritório Eduardo\ Super\ Trafo Estrada\ Tronco], allow_blank: true }
  validates :bandeira, inclusion: { in: %w[Verde Amarelo Vermelho Preto Azul Verde/Amarelo], allow_blank: true }
  validates :acquisition_price, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  
  # Validação customizada para prevenir mudança do tipo de equipamento
  validate :equipment_type_cannot_be_changed, on: :update
  validate :serial_number_format
  validate :acquisition_date_cannot_be_in_future

  # Scopes dinâmicos baseados em status
  scope :em_estoque, -> { 
    where.not(
      id: RentalEquipment.joins(:rental)
                         .where(rentals: { status: 'ativo' })
                         .select(:equipment_id)
    )
  }
  
  scope :alugado, -> { 
    joins(:rental_equipments)
    .joins('INNER JOIN rentals ON rentals.id = rental_equipments.rental_id')
    .where(rentals: { status: 'ativo' })
    .distinct
  }
  
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
  scope :recent, -> { order(created_at: :desc) }
  scope :needs_maintenance, -> { where('last_maintenance_date < ? OR last_maintenance_date IS NULL', 6.months.ago) }
  
  scope :available_for_rental, -> { em_estoque }

  # Métodos
  def display_name
    "#{equipment_type.name} #{serial_number}"
  end

  # Status dinâmico baseado em relações
  def status
    if has_active_rental?
      'alugado'
    else
      'em_estoque'
    end
  end

  def status_display
    case status
    when 'em_estoque' then 'EM ESTOQUE'
    when 'vendido' then 'VENDIDO'
    when 'alugado' then 'ALUGADO'
    else status.upcase
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
    return true if required_features.empty?

    required_features.all? { |feature| feature_value(feature.name).present? }
  end

  def age_in_days
    return nil unless acquisition_date
    (Date.current - acquisition_date).to_i
  end

  def age_in_years
    return nil unless acquisition_date
    age_in_days / 365.25
  end

  def formatted_acquisition_price
    return nil unless acquisition_price
    "R$ #{acquisition_price.to_f.round(2)}"
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

  # Métodos de status dinâmico
  def has_active_rental?
    rental_equipments.joins(:rental).where(rentals: { status: 'ativo' }).exists?
  end

  def is_rented?
    status == 'alugado'
  end

  def is_available?
    status == 'em_estoque'
  end

  def current_rental
    rentals.active.first
  end

  def can_be_rented?
    is_available?
  end

  # Métodos de manutenção
  def needs_maintenance?
    return true if last_maintenance_date.nil?
    last_maintenance_date < 6.months.ago
  end

  def maintenance_due_date
    return nil if last_maintenance_date.nil?
    last_maintenance_date + 6.months
  end

  def days_since_maintenance
    return nil if last_maintenance_date.nil?
    (Date.current - last_maintenance_date).to_i
  end

  # Métodos de busca
  def self.search(query)
    where("serial_number ILIKE ? OR notes ILIKE ?", "%#{query}%", "%#{query}%")
      .or(joins(:equipment_type).where("equipment_types.name ILIKE ?", "%#{query}%"))
      .or(where("location ILIKE ?", "%#{query}%"))
  end

  private

  def equipment_type_cannot_be_changed
    if equipment_type_id_changed?
      errors.add(:equipment_type, 'não pode ser alterado após a criação')
    end
  end

  def serial_number_format
    return if serial_number.blank?
    
    unless serial_number.match?(/^[A-Z0-9\-_]+$/i)
      errors.add(:serial_number, 'deve conter apenas letras, números, hífens e underscores')
    end
  end

  def acquisition_date_cannot_be_in_future
    return if acquisition_date.blank?
    
    if acquisition_date > Date.current
      errors.add(:acquisition_date, 'não pode ser no futuro')
    end
  end
end 