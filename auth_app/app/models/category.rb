class Category < ApplicationRecord
  has_many :equipment, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :color, presence: true

  # Definir cor padrão
  after_initialize :set_default_color, if: :new_record?
  
  def display_name
    name
  end

  def equipment_count
    equipment.count
  end

  def can_be_deleted?
    equipment.empty?
  end

  private

  def set_default_color
    self.color ||= '#3b82f6' # Azul padrão
  end
end
