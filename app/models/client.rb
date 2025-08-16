class Client < ApplicationRecord
  has_many :contacts, dependent: :destroy
  has_many :rentals, dependent: :destroy
  has_many :financial_entries
  accepts_nested_attributes_for :contacts, allow_destroy: true, reject_if: :all_blank

  # Validações
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :document_type, presence: true, inclusion: { in: %w[CNPJ CPF] }
  validates :document_number, presence: true, uniqueness: true
  validates :zip_code, presence: true, format: { with: /\A\d{5}-?\d{3}\z/, message: 'deve estar no formato 00000-000' }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, format: { with: /\A\(\d{2}\)\s\d{4,5}-\d{4}\z/, message: 'deve estar no formato (11) 99999-9999' }, allow_blank: true
  
  # Validações customizadas
  validate :document_number_format
  validate :document_number_validation
  validate :at_least_one_contact, on: :create
  
  # Definir CNPJ como padrão
  after_initialize :set_default_document_type, if: :new_record?
  
  # Scopes
  scope :active, -> { joins(:rentals).where(rentals: { status: 'ativo' }).distinct }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_document_type, ->(type) { where(document_type: type) }
  scope :with_rentals, -> { includes(:rentals) }
  scope :with_contacts, -> { includes(:contacts) }
  
  def display_name
    name
  end

  def main_contact
    contacts.first
  end

  def has_multiple_contacts?
    contacts.count > 1
  end

  def active_rentals
    rentals.active
  end

  def has_active_rentals?
    active_rentals.exists?
  end

  def total_rentals
    rentals.count
  end

  def total_billing_amount
    rentals.joins(:rental_billing_periods).sum('rental_billing_periods.amount')
  end

  def formatted_total_amount
    "R$ #{total_billing_amount.to_f.round(2).to_s.gsub('.', ',')}"
  end

  def average_rental_duration
    return nil if total_rentals.zero?
    
    total_days = rentals.joins(:rental_billing_periods).sum(
      "(rental_billing_periods.end_date - rental_billing_periods.start_date + 1)"
    )
    total_days / total_rentals
  end

  def formatted_average_duration
    return "N/A" if average_rental_duration.nil?
    "#{average_rental_duration.round(0)} dias"
  end

  # Métodos de busca
  def self.search(query)
    where("name ILIKE ? OR document_number ILIKE ? OR email ILIKE ?", 
          "%#{query}%", "%#{query}%", "%#{query}%")
      .or(joins(:contacts).where("contacts.name ILIKE ? OR contacts.email ILIKE ?", 
                                 "%#{query}%", "%#{query}%"))
  end

  # Métodos de relatório
  def rental_history
    rentals.includes(:rental_billing_periods).order(created_at: :desc)
  end

  def last_rental_date
    rentals.maximum(:created_at)
  end

  def days_since_last_rental
    return nil if last_rental_date.nil?
    (Date.current - last_rental_date.to_date).to_i
  end

  def is_regular_customer?
    total_rentals >= 3
  end

  def is_vip_customer?
    total_billing_amount > 10000
  end

  private

  def set_default_document_type
    self.document_type ||= 'CNPJ'
  end

  def document_number_format
    return if document_number.blank?
    
    case document_type
    when 'CNPJ'
      unless document_number.match?(/\A\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}\z/)
        errors.add(:document_number, 'CNPJ deve estar no formato 00.000.000/0000-00')
      end
    when 'CPF'
      unless document_number.match?(/\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/)
        errors.add(:document_number, 'CPF deve estar no formato 000.000.000-00')
      end
    end
  end

  def document_number_validation
    return if document_number.blank?
    
    case document_type
    when 'CNPJ'
      validate_cnpj
    when 'CPF'
      validate_cpf
    end
  end

  def validate_cnpj
    # Implementação básica de validação de CNPJ
    cnpj = document_number.gsub(/[^\d]/, '')
    return if cnpj.length != 14
    
    # Validação básica - em produção, usar gem específica
    errors.add(:document_number, 'CNPJ inválido') if cnpj.chars.uniq.length == 1
  end

  def validate_cpf
    # Implementação básica de validação de CPF
    cpf = document_number.gsub(/[^\d]/, '')
    return if cpf.length != 11
    
    # Validação básica - em produção, usar gem específica
    errors.add(:document_number, 'CPF inválido') if cpf.chars.uniq.length == 1
  end

  def at_least_one_contact
    if contacts.empty? || contacts.all?(&:marked_for_destruction?)
      errors.add(:base, 'pelo menos um contato deve ser informado')
    end
  end
end 