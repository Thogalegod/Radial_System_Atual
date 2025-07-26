class EquipmentFeature < ApplicationRecord
  # Relacionamentos
  belongs_to :equipment_type
  has_many :equipment_values, dependent: :destroy
  has_many :equipment_feature_options, dependent: :destroy
  has_many :equipments, through: :equipment_values

  # Validações
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :data_type, presence: true, inclusion: { in: %w[string integer float boolean date select] }
  validates :equipment_type, presence: true
  validates :name, uniqueness: { scope: :equipment_type_id }
  validates :unit, length: { maximum: 20 }
  validates :description, length: { maximum: 500 }
  validates :color, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/ }, allow_blank: true
  validates :sort_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered, -> { order(:sort_order, :name) }
  scope :required, -> { where(required: true) }
  scope :optional, -> { where(required: false) }
  scope :searchable, -> { where(searchable: true) }
  scope :filterable, -> { where(filterable: true) }
  scope :sortable, -> { where(sortable: true) }
  scope :by_data_type, ->(type) { where(data_type: type) }
  scope :select_type, -> { where(data_type: 'select') }
  scope :with_options, -> { includes(:equipment_feature_options) }

  # Callbacks
  before_validation :set_default_color, on: :create
  before_validation :set_default_icon, on: :create

  # Métodos
  def display_name
    unit.present? ? "#{name} (#{unit})" : name
  end

  def data_type_display
    case data_type
    when 'string' then 'Texto'
    when 'integer' then 'Número Inteiro'
    when 'float' then 'Número Decimal'
    when 'boolean' then 'Sim/Não'
    when 'date' then 'Data'
    when 'select' then 'Seleção'
    else data_type
    end
  end

  def data_type_icon
    case data_type
    when 'string' then 'fas fa-font'
    when 'integer' then 'fas fa-hashtag'
    when 'float' then 'fas fa-percentage'
    when 'boolean' then 'fas fa-toggle-on'
    when 'date' then 'fas fa-calendar'
    when 'select' then 'fas fa-list'
    else 'fas fa-cog'
    end
  end

  def has_options?
    data_type == 'select'
  end

  def options_array
    return [] unless has_options?
    equipment_feature_options.active.ordered.pluck(:value, :label, :color)
  end

  def option_labels
    return [] unless has_options?
    equipment_feature_options.active.ordered.pluck(:label)
  end

  def option_values
    return [] unless has_options?
    equipment_feature_options.active.ordered.pluck(:value)
  end

  def validate_value(value)
    return true if value.blank? && !required
    return false if value.blank? && required

    case data_type
    when 'string'
      true
    when 'integer'
      value.to_s.match?(/\A\d+\z/)
    when 'float'
      value.to_s.match?(/\A\d+(\.\d+)?\z/)
    when 'boolean'
      %w[true false 1 0 yes no].include?(value.to_s.downcase)
    when 'date'
      Date.parse(value.to_s) rescue false
    when 'select'
      option_values.include?(value.to_s)
    else
      false
    end
  end

  def format_value(value)
    return '' if value.blank?

    case data_type
    when 'integer'
      value.to_i.to_s
    when 'float'
      value.to_f.to_s
    when 'boolean'
      %w[true 1 yes].include?(value.to_s.downcase) ? 'Sim' : 'Não'
    when 'date'
      Date.parse(value.to_s).strftime('%d/%m/%Y') rescue value
    when 'select'
      option = equipment_feature_options.find_by(value: value.to_s)
      option&.label || value
    else
      value.to_s
    end
  end

  def css_style
    "color: #{color};" if color.present?
  end

  def input_type
    case data_type
    when 'string' then 'text'
    when 'integer' then 'number'
    when 'float' then 'number'
    when 'boolean' then 'checkbox'
    when 'date' then 'date'
    when 'select' then 'select'
    else 'text'
    end
  end

  def input_step
    case data_type
    when 'float' then '0.01'
    when 'integer' then '1'
    else nil
    end
  end

  # Cache methods
  def self.cached_by_type(equipment_type_id)
    Rails.cache.fetch("equipment_features_type_#{equipment_type_id}", expires_in: 30.minutes) do
      where(equipment_type_id: equipment_type_id).ordered.to_a
    end
  end

  def self.cached_filterable_by_type(equipment_type_id)
    Rails.cache.fetch("equipment_features_filterable_type_#{equipment_type_id}", expires_in: 30.minutes) do
      where(equipment_type_id: equipment_type_id).filterable.ordered.to_a
    end
  end

  def cached_options
    Rails.cache.fetch("equipment_feature_#{id}_options", expires_in: 30.minutes) do
      equipment_feature_options.active.ordered.to_a
    end
  end

  def cached_options_for_select
    Rails.cache.fetch("equipment_feature_#{id}_options_select", expires_in: 30.minutes) do
      equipment_feature_options.active.ordered.map { |option| [option.label, option.value] }
    end
  end

  # Cache invalidation
  after_commit :clear_cache
  after_destroy :clear_cache

  private

  def set_default_color
    self.color = '#6B7280' if color.blank?
  end

  def set_default_icon
    self.icon_class = data_type_icon if icon_class.blank?
  end

  def clear_cache
    Rails.cache.delete_matched("equipment_features_type_#{equipment_type_id}*")
    Rails.cache.delete_matched("equipment_feature_#{id}_*")
  end
end 