class Rental < ApplicationRecord
  belongs_to :client

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

  # Scopes úteis
  scope :active, -> { where(status: 'ativo') }
  scope :completed, -> { where(status: 'concluido') }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }

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

  def display_name
    "#{name} - #{client.name}"
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
end
