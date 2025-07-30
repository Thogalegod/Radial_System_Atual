class Rental < ApplicationRecord
  belongs_to :client
  has_many :rental_equipments, dependent: :destroy
  has_many :equipments, through: :rental_equipments
  has_many :rental_billing_periods, dependent: :destroy

  # Enum para status
  enum :status, { ativo: 'ativo', concluido: 'concluido' }

  # Validações
  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :client, presence: true
  validates :remessa_note, length: { maximum: 50 }

  validate :cannot_conclude_without_equipments, on: :update

  # Scopes
  scope :active, -> { where(status: 'ativo') }
  scope :completed, -> { where(status: 'concluido') }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :with_equipments, -> { includes(:equipments) }
  scope :recent, -> { order(created_at: :desc) }

  def display_name
    "#{name} - #{client.name}"
  end

  def is_active?
    status == 'ativo'
  end

  def is_completed?
    status == 'concluido'
  end

  def can_be_completed?
    is_active? && equipments.any?
  end

  def add_equipment(equipment)
    # Verifica se o equipamento já está em uma locação ATIVA
    return false if equipment.rental_equipments.joins(:rental).where(rentals: { status: 'ativo' }).exists?
    
    rental_equipments.create(equipment: equipment)
  end

  def remove_equipment(equipment)
    rental_equipment = rental_equipments.find_by(equipment: equipment)
    return false unless rental_equipment
    
    # Remove a associação
    rental_equipment.destroy
    
    true
  end

  def complete!
    return false unless can_be_completed?
    
    update(status: 'concluido')
  end

  def reactivate!
    return false if is_active?
    
    update(status: 'ativo')
  end

  def equipment_count
    equipments.count
  end

  def has_equipments?
    equipments.any?
  end

  def total_billing_amount
    rental_billing_periods.sum(:amount)
  end

  def formatted_total_amount
    "R$ #{total_billing_amount.to_f.round(2).to_s.gsub('.', ',')}"
  end

  def billing_periods_count
    rental_billing_periods.count
  end

  def has_billing_periods?
    rental_billing_periods.any?
  end

  def active_billing_period
    rental_billing_periods.active.first
  end

  def can_add_billing_period?
    is_active?
  end

  def generate_debit_note_number(period)
    # Formato: RC[nome_locacao]-[sequencial]
    # Exemplo: RC20250721-1, RC20250721-2
    return "RC#{name.gsub(/[^a-zA-Z0-9]/, '').upcase}-0" if period.nil?
    
    base_name = name.gsub(/[^a-zA-Z0-9]/, '').upcase
    sequence = rental_billing_periods.where('id <= ?', period.id).count
    "RC#{base_name}-#{sequence}"
  end

  def has_remessa_note?
    remessa_note.present?
  end

  def remessa_note_display
    has_remessa_note? ? remessa_note : '-'
  end

  private

  def cannot_conclude_without_equipments
    if status_changed? && status == 'concluido' && equipments.empty?
      errors.add(:status, 'não pode ser concluído sem equipamentos')
    end
  end
end
