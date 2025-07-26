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
