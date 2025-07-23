class Client < ApplicationRecord
  has_many :contacts, dependent: :destroy
  accepts_nested_attributes_for :contacts, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :document_type, presence: true
  validates :document_number, presence: true, uniqueness: true
  validates :zip_code, presence: true
  
  # Definir CNPJ como padrão
  after_initialize :set_default_document_type, if: :new_record?
  
  def display_name
    name
  end

  def main_contact
    contacts.where(is_primary: true).first || contacts.first
  end

  def has_multiple_contacts?
    contacts.count > 1
  end

  private

  def set_default_document_type
    self.document_type ||= 'CNPJ'
  end
end 