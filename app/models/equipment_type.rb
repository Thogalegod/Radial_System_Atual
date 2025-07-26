class EquipmentType < ApplicationRecord
  # Relacionamentos
  has_many :equipments, dependent: :destroy
  has_many :equipment_features, dependent: :destroy
  has_many :equipment_feature_options, through: :equipment_features

  # Validações
  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :icon_class, presence: true
  validates :primary_color, presence: true, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/ }
  validates :secondary_color, presence: true, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/ }
  validates :accent_color, presence: true, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/ }
  validates :sort_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :name) }
  scope :with_equipments, -> { includes(:equipments) }
  scope :with_features, -> { includes(:equipment_features) }

  # Callbacks
  before_validation :set_default_colors, on: :create
  before_validation :set_default_icon, on: :create

  # Métodos
  def display_name
    name
  end

  def color
    primary_color
  end

  def equipment_count
    equipments.count
  end

  def feature_count
    equipment_features.count
  end

  def css_variables
    {
      '--primary-color': primary_color,
      '--secondary-color': secondary_color,
      '--accent-color': accent_color
    }
  end

  def css_style
    css_variables.map { |key, value| "#{key}: #{value}" }.join('; ')
  end

  # Cache methods
  def self.cached_active
    Rails.cache.fetch("equipment_types_active", expires_in: 1.hour) do
      active.ordered.to_a
    end
  end

  def self.cached_with_equipments
    Rails.cache.fetch("equipment_types_with_equipments", expires_in: 30.minutes) do
      active.includes(:equipments).ordered.to_a
    end
  end

  def self.cached_with_features
    Rails.cache.fetch("equipment_types_with_features", expires_in: 30.minutes) do
      active.includes(:equipment_features).ordered.to_a
    end
  end

  def cached_equipment_count
    Rails.cache.fetch("equipment_type_#{id}_equipment_count", expires_in: 15.minutes) do
      equipments.count
    end
  end

  def cached_feature_count
    Rails.cache.fetch("equipment_type_#{id}_feature_count", expires_in: 15.minutes) do
      equipment_features.count
    end
  end

  def cached_features
    Rails.cache.fetch("equipment_type_#{id}_features", expires_in: 30.minutes) do
      equipment_features.ordered.to_a
    end
  end

  def cached_filterable_features
    Rails.cache.fetch("equipment_type_#{id}_filterable_features", expires_in: 30.minutes) do
      equipment_features.filterable.ordered.to_a
    end
  end

  # Cache invalidation
  after_commit :clear_cache
  after_destroy :clear_cache

  private

  def set_default_colors
    return if primary_color.present?

    # Cores padrão modernas
    self.primary_color = '#3B82F6'    # Blue
    self.secondary_color = '#1E40AF'  # Dark Blue
    self.accent_color = '#DBEAFE'     # Light Blue
  end

  def set_default_icon
    self.icon_class = 'fas fa-cog' if icon_class.blank?
  end

  def clear_cache
    Rails.cache.delete_matched("equipment_types_*")
    Rails.cache.delete_matched("equipment_type_#{id}_*")
  end
end
