class MediumVoltageTransformer < ApplicationRecord
  belongs_to :bt_option
  belongs_to :location, optional: true
  belongs_to :status, optional: true
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
end
