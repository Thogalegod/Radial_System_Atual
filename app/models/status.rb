require 'digest'

class Status < ApplicationRecord
  has_many :medium_voltage_transformers
  validates :value, presence: true, uniqueness: true
  before_save :set_color
  before_destroy :check_for_associated_transformers

  private

  def set_color
    self.color = "##{Digest::MD5.hexdigest(value.to_s)[0..5]}"
  end

  def check_for_associated_transformers
    if medium_voltage_transformers.any?
      errors.add(:base, "Não é possível excluir este status pois está sendo usado por #{medium_voltage_transformers.count} transformador(es)")
      throw(:abort)
    end
  end
end
