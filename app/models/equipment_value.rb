class EquipmentValue < ApplicationRecord
  # Relacionamentos
  belongs_to :equipment, foreign_key: 'equipments_id'
  belongs_to :equipment_feature

  # Validações
  validates :equipment, presence: true
  validates :equipment_feature, presence: true
  validates :equipment_feature_id, uniqueness: { scope: :equipments_id }
  validates :value, length: { maximum: 500 }
  validates :color, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/ }, allow_blank: true
  validates :style_class, length: { maximum: 100 }

  # Callbacks
  before_validation :validate_feature_value
  before_validation :set_default_color

  # Scopes
  scope :with_feature, -> { includes(:equipment_feature) }
  scope :with_equipment, -> { includes(:equipment) }
  scope :by_feature, ->(feature_id) { where(equipment_feature_id: feature_id) }
  scope :by_value, ->(value) { where(value: value) }
  scope :with_value, -> { where.not(value: [nil, '']) }
  scope :without_value, -> { where(value: [nil, '']) }

  # Métodos
  def display_value
    return '' if value.blank?
    return value.to_s unless equipment_feature
    equipment_feature.format_value(value)
  end

  def raw_value
    value
  end

  def formatted_value
    return '' if value.blank?
    return value.to_s unless equipment_feature
    
    case equipment_feature.data_type
    when 'boolean'
      %w[true 1 yes].include?(value.to_s.downcase) ? 'Sim' : 'Não'
    when 'date'
      Date.parse(value.to_s).strftime('%d/%m/%Y') rescue value
    when 'select'
      option = equipment_feature.equipment_feature_options.find_by(value: value.to_s)
      option&.label || value
    else
      value.to_s
    end
  end

  def css_style
    styles = []
    styles << "color: #{color};" if color.present?
    styles << style_class if style_class.present?
    styles.join(' ')
  end

  def option_color
    return color if color.present?
    return equipment_feature.color if equipment_feature&.color.present?
    return '#6B7280' unless equipment_feature
    
    # Cor padrão baseada no tipo de dado
    case equipment_feature.data_type
    when 'boolean'
      %w[true 1 yes].include?(value.to_s.downcase) ? '#10B981' : '#EF4444'
    when 'select'
      option = equipment_feature.equipment_feature_options.find_by(value: value.to_s)
      option&.color || '#6B7280'
    else
      '#6B7280'
    end
  end

  def option_icon
    return nil unless equipment_feature&.data_type == 'select'
    
    option = equipment_feature.equipment_feature_options.find_by(value: value.to_s)
    option&.icon_class
  end

  def is_boolean_true?
    return false unless equipment_feature&.data_type == 'boolean'
    %w[true 1 yes].include?(value.to_s.downcase)
  end

  def is_boolean_false?
    return false unless equipment_feature&.data_type == 'boolean'
    %w[false 0 no].include?(value.to_s.downcase)
  end

  def has_value?
    value.present?
  end

  def empty?
    value.blank?
  end

  def update_value(new_value, new_color = nil)
    self.value = new_value
    self.color = new_color if new_color.present?
    save
  end

  private

  def validate_feature_value
    return if value.blank?
    return unless equipment_feature
    
    unless equipment_feature.validate_value(value)
      errors.add(:value, "não é válido para o tipo de dado '#{equipment_feature.data_type_display}'")
    end
  end

  def set_default_color
    return if color.present?
    return unless equipment_feature
    
    # Usar cor da opção se for select
    if equipment_feature.data_type == 'select' && value.present?
      option = equipment_feature.equipment_feature_options.find_by(value: value.to_s)
      self.color = option&.color if option&.color.present?
    end
    
    # Usar cor da característica como fallback
    self.color = equipment_feature.color if color.blank? && equipment_feature.color.present?
  end
end 