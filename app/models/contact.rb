class Contact < ApplicationRecord
  belongs_to :client

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :position, presence: true
  
  before_save :ensure_primary_contact
  
  private
  
  def ensure_primary_contact
    # Se este contato está sendo marcado como principal, desmarca os outros
    if is_primary?
      client.contacts.where.not(id: id).update_all(is_primary: false)
    end
    
    # Se não há contatos principais e este é o primeiro contato do cliente, marca como principal
    if client.contacts.where(is_primary: true).count == 0 && client.contacts.count == 1
      self.is_primary = true
    end
  end
end 