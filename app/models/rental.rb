class Rental < ApplicationRecord
  belongs_to :client
  has_many :rental_equipments, dependent: :destroy
  has_many :equipments, through: :rental_equipments

  # Enum para status
  enum :status, { ativo: 'ativo', concluido: 'concluido' }

  # Validações
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :client, presence: true

  # Validação customizada para datas
  validate :end_date_after_start_date
  validate :start_date_not_in_past, on: :create
  validate :cannot_conclude_without_equipments, on: :update

  # Scopes
  scope :active, -> { where(status: 'ativo') }
  scope :completed, -> { where(status: 'concluido') }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :with_equipments, -> { includes(:equipments) }
  scope :recent, -> { order(created_at: :desc) }

  def duration_days
    return 0 unless start_date && end_date
    (end_date - start_date).to_i
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

  def display_name
    "#{name} - #{client.name}"
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

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    
    if end_date <= start_date
      errors.add(:end_date, 'deve ser posterior à data de início')
    end
  end

  def start_date_not_in_past
    return if start_date.blank?
    
    if start_date < Date.current
      errors.add(:start_date, 'não pode ser no passado')
    end
  end

  def cannot_conclude_without_equipments
    if status_changed? && status == 'concluido' && equipments.empty?
      errors.add(:status, 'não pode ser concluído sem equipamentos')
    end
  end
end
