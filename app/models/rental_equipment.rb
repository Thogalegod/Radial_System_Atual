class RentalEquipment < ApplicationRecord
  belongs_to :rental
  belongs_to :equipment
end
