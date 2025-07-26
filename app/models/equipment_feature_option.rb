class EquipmentFeatureOption < ApplicationRecord
  # Relacionamentos
  belongs_to :equipment_feature

  # Validações
  validates :value, presence: true, length: { minimum: 1, maximum: 100 }
  validates :label, length: { maximum: 200 }
  validates :equipment_feature, presence: true
  validates :value, uniqueness: { scope: :equipment_feature_id }
  validates :color, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/ }, allow_blank: true
  validates :sort_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :icon_class, length: { maximum: 100 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :label, :value) }
  scope :by_value, ->(value) { where(value: value) }
  scope :by_label, ->(label) { where(label: label) }

  # Callbacks
  before_validation :set_default_color, on: :create
  before_validation :set_default_label, on: :create

  # Métodos
  def display_name
    label.present? ? label : value
  end

  def display_value
    value
  end

  def css_style
    styles = []
    styles << "color: #{color};" if color.present?
    styles << "background-color: #{color}20;" if color.present? # 20 = 12% opacity
    styles.join(' ')
  end

  def badge_style
    "background-color: #{color}; color: white;" if color.present?
  end

  def icon_with_label
    return display_name unless icon_class.present?
    "<i class='#{icon_class}'></i> #{display_name}".html_safe
  end

  def is_selected?(current_value)
    value.to_s == current_value.to_s
  end

  def toggle_active!
    update!(active: !active)
  end

  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end

  def move_up!
    return if sort_order <= 0
    
    previous_option = equipment_feature.equipment_feature_options
                                      .where(sort_order: sort_order - 1)
                                      .first
    
    if previous_option
      previous_option.update!(sort_order: sort_order)
      update!(sort_order: sort_order - 1)
    end
  end

  def move_down!
    next_option = equipment_feature.equipment_feature_options
                                  .where(sort_order: sort_order + 1)
                                  .first
    
    if next_option
      next_option.update!(sort_order: sort_order)
      update!(sort_order: sort_order + 1)
    end
  end

  def usage_count
    equipment_feature.equipment_values.where(value: value).count
  end

  def is_used?
    usage_count > 0
  end

  def can_be_deleted?
    !is_used?
  end

  private

  def set_default_color
    return if color.present?
    
    # Cores padrão baseadas no valor
    case value.to_s.downcase
    when /sim|yes|true|ativo|active/
      self.color = '#10B981' # Green
    when /não|no|false|inativo|inactive/
      self.color = '#EF4444' # Red
    when /manutenção|maintenance/
      self.color = '#F59E0B' # Yellow
    when /emergência|emergency/
      self.color = '#DC2626' # Red
    when /normal|ok/
      self.color = '#3B82F6' # Blue
    else
      self.color = '#6B7280' # Gray
    end
  end

  def set_default_label
    self.label = value.titleize if label.blank?
  end
end 