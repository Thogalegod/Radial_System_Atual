class MediumVoltageTransformer < ApplicationRecord
  belongs_to :bt_option
  belongs_to :power_option, optional: true
  belongs_to :location, optional: true
  belongs_to :status, optional: true
  belongs_to :cooling_option, optional: true
  belongs_to :flag_option, optional: true
  belongs_to :installation_option, optional: true
  validates :serial_number, presence: true, uniqueness: true
  validates :bt_option, presence: true

  # Scopes para filtros
  scope :with_bt_option, -> { joins(:bt_option) }
  scope :with_power_option, -> { joins(:power_option) }
  scope :with_location, -> { joins(:location) }
  scope :with_status, -> { joins(:status) }
  scope :with_cooling_option, -> { joins(:cooling_option) }
  scope :with_flag_option, -> { joins(:flag_option) }
  scope :with_installation_option, -> { joins(:installation_option) }
  
  scope :without_location, -> { where(location: nil) }
  scope :without_status, -> { where(status: nil) }
  scope :without_power_option, -> { where(power_option: nil) }
  scope :with_notes, -> { where.not(notes: [nil, '']) }
  scope :without_notes, -> { where(notes: [nil, '']) }
  
  # Ordenação
  scope :ordered_by_serial_number, -> { order(:serial_number) }
  scope :ordered_by_serial_number_desc, -> { order(serial_number: :desc) }
  scope :ordered_by_bt_option, -> { joins(:bt_option).order('bt_options.value') }
  scope :ordered_by_bt_option_desc, -> { joins(:bt_option).order('bt_options.value DESC') }
  scope :ordered_by_power_option, -> { joins(:power_option).order('power_options.value') }
  scope :ordered_by_power_option_desc, -> { joins(:power_option).order('power_options.value DESC') }
  scope :ordered_by_location, -> { joins(:location).order('locations.value') }
  scope :ordered_by_location_desc, -> { joins(:location).order('locations.value DESC') }
  scope :ordered_by_status, -> { joins(:status).order('statuses.value') }
  scope :ordered_by_status_desc, -> { joins(:status).order('statuses.value DESC') }
  scope :ordered_by_cooling_option, -> { joins(:cooling_option).order('cooling_options.value') }
  scope :ordered_by_cooling_option_desc, -> { joins(:cooling_option).order('cooling_options.value DESC') }
  scope :ordered_by_flag_option, -> { joins(:flag_option).order('flag_options.value') }
  scope :ordered_by_flag_option_desc, -> { joins(:flag_option).order('flag_options.value DESC') }
  scope :ordered_by_installation_option, -> { joins(:installation_option).order('installation_options.value') }
  scope :ordered_by_installation_option_desc, -> { joins(:installation_option).order('installation_options.value DESC') }
  scope :ordered_by_created_at, -> { order(:created_at) }
  scope :ordered_by_created_at_desc, -> { order(created_at: :desc) }
  scope :ordered_by_updated_at, -> { order(:updated_at) }
  scope :ordered_by_updated_at_desc, -> { order(updated_at: :desc) }

  def display_name
    "Transformador MT #{serial_number}"
  end

  def voltage_display
    "#{bt_option.value} V"
  end

  def location_display
    location&.value || "Não definida"
  end

  def status_display
    status&.value || "Não definido"
  end

  def power_display
    power_option ? "#{power_option.value} kVA" : "Não definida"
  end

  def cooling_display
    cooling_option&.value || "Não definida"
  end

  def flag_display
    flag_option&.value || "Não definida"
  end

  def installation_display
    installation_option&.value || "Não definida"
  end
end
