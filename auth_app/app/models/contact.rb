class Contact < ApplicationRecord
  belongs_to :client

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :position, presence: true
  

end 