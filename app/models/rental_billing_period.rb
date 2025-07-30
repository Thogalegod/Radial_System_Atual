class RentalBillingPeriod < ApplicationRecord
  belongs_to :rental

  # Validações
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :rental, presence: true
  validates :client_order, length: { maximum: 200 }
  validates :observations, length: { maximum: 1000 }

  # Validações customizadas
  validate :end_date_after_start_date
  validate :no_overlapping_periods

  # Scopes
  scope :ordered_by_date, -> { order(:start_date) }
  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :future, -> { where('start_date > ?', Date.current) }
  scope :past, -> { where('end_date < ?', Date.current) }

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

  private

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
end
