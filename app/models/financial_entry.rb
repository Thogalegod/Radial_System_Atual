class FinancialEntry < ApplicationRecord
  # Associações
  belongs_to :client, optional: true
  belongs_to :reference, polymorphic: true, optional: true
  
  # Anexos (comprovantes, notas, etc.)
  has_many_attached :attachments

  # Validações
  # Exigir cliente apenas na criação para não bloquear atualizações de status
  validates :client, presence: true, if: -> { entry_type == 'receivable' }, on: :create
  validates :description, presence: true, length: { minimum: 3, maximum: 200 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending paid overdue cancelled] }
  validates :entry_type, presence: true, inclusion: { in: %w[receivable payable] }
  validates :company, inclusion: { in: ['Fontes Energia', 'Radial Equipamentos'], allow_blank: true }

  # Scopes
  scope :for_client, ->(client_id) { where(client_id: client_id) }
  scope :receivable, -> { where(entry_type: 'receivable') }
  scope :payable, -> { where(entry_type: 'payable') }
  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :overdue, -> { where(status: 'overdue') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :by_due_date, -> { order(:due_date) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_month, ->(date) { where(due_date: date.all_month) }
  scope :by_company, ->(name) { where(company: name) }

  # Métodos de status
  def is_pending?
    status == 'pending'
  end

  def is_paid?
    status == 'paid'
  end

  def is_overdue?
    status == 'overdue' || (status == 'pending' && due_date < Date.current)
  end

  def is_cancelled?
    status == 'cancelled'
  end

  # Métodos de cálculo
  def days_until_due
    return nil if due_date.nil?
    (due_date - Date.current).to_i
  end

  def days_overdue
    return 0 unless is_overdue?
    (Date.current - due_date).to_i
  end

  def formatted_amount
    "R$ #{amount.to_f.round(2).to_s.gsub('.', ',')}"
  end

  def formatted_due_date
    due_date&.strftime('%d/%m/%Y')
  end

  def formatted_paid_date
    paid_date&.strftime('%d/%m/%Y')
  end

  def has_paid_date?
    paid_date.present?
  end

  def days_to_pay
    return nil unless paid_date && due_date
    (paid_date - due_date).to_i
  end

  def was_paid_on_time?
    return nil unless paid_date && due_date
    paid_date <= due_date
  end

  # Métodos de status display
  def status_display
    case status
    when 'pending' then 'PENDENTE'
    when 'paid' then 'PAGO'
    when 'overdue' then 'VENCIDO'
    when 'cancelled' then 'CANCELADO'
    else 'DESCONHECIDO'
    end
  end

  def status_color
    case status
    when 'pending' then '#3B82F6'  # Blue
    when 'paid' then '#10B981'     # Green
    when 'overdue' then '#EF4444'  # Red
    when 'cancelled' then '#6B7280' # Gray
    else '#EF4444' # Red
    end
  end

  # Métodos de busca
  def self.search(query)
    sanitized = "%#{sanitize_sql_like(query)}%"
    left_joins(:client)
      .joins("LEFT JOIN rental_billing_periods rbp ON rbp.id = financial_entries.reference_id AND financial_entries.reference_type = 'RentalBillingPeriod'")
      .where(
        "financial_entries.description ILIKE :q
         OR CAST(financial_entries.id AS TEXT) ILIKE :q
         OR clients.name ILIKE :q
         OR rbp.client_order ILIKE :q",
        q: sanitized
      )
  end

  # Callback para atualizar status automaticamente
  before_validation :update_status_based_on_due_date, if: :due_date_changed?
  before_validation :assign_client_from_reference, if: -> { client_id.blank? && reference.present? }

  private

  def update_status_based_on_due_date
    return if is_cancelled? || is_paid?
    
    if due_date < Date.current && status == 'pending'
      self.status = 'overdue'
    elsif due_date >= Date.current && status == 'overdue'
      self.status = 'pending'
    end
  end

  def assign_client_from_reference
    case reference
    when RentalBillingPeriod
      self.client_id = reference.rental&.client_id
    end
  end
end
