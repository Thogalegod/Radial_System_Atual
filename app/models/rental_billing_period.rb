class RentalBillingPeriod < ApplicationRecord
  belongs_to :rental
  has_one :financial_entry, as: :reference, dependent: :destroy

  # Validações
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :rental, presence: true
  validates :client_order, length: { maximum: 200 }
  validates :observations, length: { maximum: 1000 }
  validate :start_date_not_in_future, on: :create
  validate :amount_format

  # Validações customizadas
  validate :end_date_after_start_date
  validate :no_overlapping_periods

  # Scopes
  scope :ordered_by_date, -> { order(:start_date) }
  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :future, -> { where('start_date > ?', Date.current) }
  scope :past, -> { where('end_date < ?', Date.current) }
  scope :by_rental, ->(rental_id) { where(rental_id: rental_id) }
  scope :with_rental, -> { includes(:rental) }
  scope :recent, -> { order(created_at: :desc) }

  # Métodos
  def duration_days
    return 0 unless start_date && end_date
    (end_date - start_date).to_i + 1
  end

  def is_active?
    start_date <= Date.current && end_date >= Date.current
  end

  def is_future?
    start_date > Date.current
  end

  def is_past?
    end_date < Date.current
  end

  def formatted_amount
    "R$ #{amount.to_f.round(2).to_s.gsub('.', ',')}"
  end

  def display_name
    "#{name} (#{start_date.strftime('%d/%m/%Y')} - #{end_date.strftime('%d/%m/%Y')})"
  end

  def has_client_order?
    client_order.present?
  end

  def has_observations?
    observations.present?
  end

  # Métodos de cálculo
  def daily_rate
    return nil if duration_days.zero?
    amount / duration_days
  end

  def formatted_daily_rate
    return "N/A" if daily_rate.nil?
    "R$ #{daily_rate.round(2)}"
  end

  def days_until_start
    return nil if start_date.nil?
    (start_date - Date.current).to_i
  end

  def days_until_end
    return nil if end_date.nil?
    (end_date - Date.current).to_i
  end

  def is_overdue?
    end_date < Date.current && amount > 0
  end

  def days_overdue
    return 0 unless is_overdue?
    (Date.current - end_date).to_i
  end

  # Métodos de status
  def status
    if is_active?
      'ativo'
    elsif is_future?
      'futuro'
    elsif is_past?
      'concluido'
    else
      'desconhecido'
    end
  end

  def status_display
    case status
    when 'ativo' then 'ATIVO'
    when 'futuro' then 'FUTURO'
    when 'concluido' then 'CONCLUÍDO'
    else 'DESCONHECIDO'
    end
  end

  def status_color
    case status
    when 'ativo' then '#10B981'  # Green
    when 'futuro' then '#3B82F6' # Blue
    when 'concluido' then '#6B7280' # Gray
    else '#EF4444' # Red
    end
  end

  # Métodos de integração financeira
  def create_financial_entry
    return if financial_entry.present?
    
    FinancialEntry.create!(
      description: "Período de Faturamento: #{name} - #{rental.display_name}",
      amount: amount,
      due_date: end_date,
      status: 'pending',
      entry_type: 'receivable',
      reference: self,
      notes: "Gerado automaticamente do período de faturamento #{id}"
    )
  end

  def regenerate_financial_entry
    if financial_entry.present?
      # Atualizar o lançamento existente em vez de recriar
      financial_entry.update!(
        description: "Período de Faturamento: #{name} - #{rental.display_name}",
        amount: amount,
        due_date: end_date
      )
    else
      create_financial_entry
    end
  end

  def has_financial_entry?
    financial_entry.present?
  end

  def financial_entry_status
    return 'N/A' unless has_financial_entry?
    financial_entry.status_display
  end

  def financial_entry_status_color
    return '#6B7280' unless has_financial_entry?
    financial_entry.status_color
  end

  # Métodos de busca
  def self.search(query)
    where("name ILIKE ? OR client_order ILIKE ? OR observations ILIKE ?", 
          "%#{query}%", "%#{query}%", "%#{query}%")
  end

  # Métodos de relatório
  def self.total_amount_by_period(start_date, end_date)
    where(start_date: start_date..end_date).sum(:amount)
  end

  def self.average_daily_rate
    periods = where.not(amount: 0)
    return 0 if periods.empty?
    
    total_amount = periods.sum(:amount)
    total_days = periods.sum { |p| p.duration_days }
    total_days.zero? ? 0 : total_amount / total_days
  end

  # Callbacks
  after_create :create_financial_entry_automatically
  after_update :update_financial_entry_description

  private

  def create_financial_entry_automatically
    create_financial_entry
  end

  def update_financial_entry_description
    return unless financial_entry.present?
    
    # Atualizar apenas a descrição quando o período for editado
    financial_entry.update_column(:description, "Período de Faturamento: #{name} - #{rental.display_name}")
  end

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    
    if end_date <= start_date
      errors.add(:end_date, 'deve ser posterior à data de início')
    end
  end

  def no_overlapping_periods
    return if start_date.blank? || end_date.blank? || rental.blank?
    
    overlapping = rental.rental_billing_periods
                       .where.not(id: id) # Exclui o próprio período se estiver sendo editado
                       .where(
                         '(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?) OR (start_date >= ? AND end_date <= ?)',
                         end_date, start_date, # Período existente contém o novo
                         start_date, end_date, # Novo período contém o existente
                         start_date, end_date  # Novo período está dentro do existente
                       )
    
    if overlapping.exists?
      errors.add(:base, 'período sobrepõe outro período existente')
    end
  end

  def start_date_not_in_future
    return if start_date.blank?
    
    if start_date > Date.current
      errors.add(:start_date, 'não pode ser no futuro')
    end
  end

  def amount_format
    return if amount.blank?
    
    if amount < 0
      errors.add(:amount, 'não pode ser negativo')
    end
    
    if amount > 999999.99
      errors.add(:amount, 'não pode ser maior que R$ 999.999,99')
    end
  end
end
