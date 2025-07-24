class Equipment < ApplicationRecord
  belongs_to :category

  validates :number, presence: true, uniqueness: true
  validates :status, presence: true
  validates :power, presence: true
  validates :voltage, presence: true
  validates :location, presence: true
  validates :category, presence: true

  # Definir status padrão
  after_initialize :set_default_status, if: :new_record?
  
  def display_name
    "#{category.name} #{number}"
  end

  def status_badge_class
    case status&.downcase
    when 'ativo', 'operacional'
      'badge-success'
    when 'manutenção', 'em manutenção'
      'badge-warning'
    when 'inativo', 'fora de serviço'
      'badge-danger'
    else
      'badge-secondary'
    end
  end

  def power_display
    "#{power} kVA"
  end

  def voltage_display
    "#{voltage} kV"
  end

  private

  def set_default_status
    self.status ||= 'Ativo'
  end
end
