class Rental < ApplicationRecord
  belongs_to :client
  has_many :rental_equipments, dependent: :destroy
  has_many :equipments, through: :rental_equipments
  has_many :rental_billing_periods, dependent: :destroy

  # Enum para status
  enum :status, { ativo: 'ativo', concluido: 'concluido' }

  # Validações
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :client, presence: true
  validates :remessa_note, length: { maximum: 50 }
  validate :name_format
  validate :cannot_conclude_without_equipments, on: :update

  # Scopes
  scope :active, -> { where(status: 'ativo') }
  scope :completed, -> { where(status: 'concluido') }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :with_equipments, -> { includes(:equipments) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_client, ->(client_id) { where(client_id: client_id) }
  scope :with_billing_periods, -> { includes(:rental_billing_periods) }
  scope :with_overdue_periods, -> { 
    joins(:rental_billing_periods)
    .where('rental_billing_periods.end_date < ? AND rentals.status = ?', Date.current, 'ativo')
    .where('rental_billing_periods.id = (SELECT MAX(rbp.id) FROM rental_billing_periods rbp WHERE rbp.rental_id = rentals.id)')
    .distinct
  }

  # Callbacks
  after_update :update_financial_entries_description

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

  # Métodos de status de período
  def last_billing_period
    rental_billing_periods.order(:end_date).last
  end

  def current_billing_period
    rental_billing_periods.active.first
  end

  def has_overdue_period?
    return false unless is_active?
    last_period = last_billing_period
    return false unless last_period
    last_period.end_date < Date.current
  end

  def days_overdue
    return 0 unless has_overdue_period?
    (Date.current - last_billing_period.end_date).to_i
  end

  def amount_overdue
    return 0 unless has_overdue_period?
    last_billing_period&.amount || 0
  end

  def period_status
    return 'concluida' if is_completed?
    return 'sem_periodos' unless has_billing_periods?
    
    if has_overdue_period?
      'vencido'
    elsif current_billing_period
      'ativo'
    else
      'sem_periodos'
    end
  end

  def period_status_display
    case period_status
    when 'ativo' then 'ATIVO'
    when 'vencido' then 'VENCIDO'
    when 'concluida' then 'CONCLUÍDA'
    when 'sem_periodos' then 'SEM PERÍODOS'
    else 'DESCONHECIDO'
    end
  end

  def period_status_color
    case period_status
    when 'ativo' then 'success'
    when 'vencido' then 'danger'
    when 'concluida' then 'secondary'
    when 'sem_periodos' then 'warning'
    else 'light'
    end
  end

  def period_status_icon
    case period_status
    when 'ativo' then 'fas fa-check-circle'
    when 'vencido' then 'fas fa-exclamation-triangle'
    when 'concluida' then 'fas fa-check-double'
    when 'sem_periodos' then 'fas fa-clock'
    else 'fas fa-question-circle'
    end
  end

  def period_status_badge_class
    case period_status
    when 'ativo' then 'badge-success'
    when 'vencido' then 'badge-danger'
    when 'concluida' then 'badge-secondary'
    when 'sem_periodos' then 'badge-warning'
    else 'badge-light'
    end
  end

  def period_status_alert_class
    case period_status
    when 'ativo' then 'alert-success'
    when 'vencido' then 'alert-danger'
    when 'concluida' then 'alert-secondary'
    when 'sem_periodos' then 'alert-warning'
    else 'alert-light'
    end
  end

  def period_status_text_color
    case period_status
    when 'ativo' then 'text-success'
    when 'vencido' then 'text-danger'
    when 'concluida' then 'text-secondary'
    when 'sem_periodos' then 'text-warning'
    else 'text-muted'
    end
  end

  def needs_new_period?
    period_status == 'vencido' || period_status == 'sem_periodos'
  end

  def next_period_suggested_start_date
    return Date.current unless last_billing_period
    last_billing_period.end_date + 1.day
  end

  # Métodos de busca
  def self.search(query)
    where("name ILIKE ? OR remessa_note ILIKE ?", "%#{query}%", "%#{query}%")
      .or(joins(:client).where("clients.name ILIKE ?", "%#{query}%"))
  end

  # Métodos de relatório
  def duration_in_days
    return nil unless rental_billing_periods.any?
    
    periods = rental_billing_periods.order(:start_date)
    start_date = periods.first.start_date
    end_date = periods.last.end_date
    (end_date - start_date).to_i + 1
  end

  def average_daily_rate
    return nil if total_billing_amount.zero? || duration_in_days.nil?
    total_billing_amount / duration_in_days
  end

  def formatted_average_daily_rate
    return "N/A" if average_daily_rate.nil?
    "R$ #{average_daily_rate.round(2)}"
  end

  private

  def update_financial_entries_description
    # Atualiza as descrições de todos os lançamentos financeiros relacionados a esta locação
    # Só executar se o nome realmente mudou
    return unless name_previous_change.present?
    
    rental_billing_periods.includes(:financial_entry).each do |period|
      if period.financial_entry.present?
        new_description = "Período de Faturamento: #{period.name} - #{display_name}"
        period.financial_entry.update_column(:description, new_description)
      end
    end
  end

  def cannot_conclude_without_equipments
    if status_changed? && status == 'concluido' && equipments.empty?
      errors.add(:status, 'não pode ser concluído sem equipamentos')
    end
  end

  def name_format
    return if name.blank?
    
    unless name.match?(/^[A-Za-z0-9\s\-_]+$/)
      errors.add(:name, 'deve conter apenas letras, números, espaços, hífens e underscores')
    end
  end
end
