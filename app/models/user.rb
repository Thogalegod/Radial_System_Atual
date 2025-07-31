class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "deve ser um email válido" }
  
  # Validação de senha forte
  validate :password_strength, if: :password_required?
  
  private
  
  def password_required?
    new_record? || password.present?
  end
  
  def password_strength
    return if password.blank?
    
    errors.add(:password, "deve ter pelo menos 8 caracteres") if password.length < 8
    errors.add(:password, "deve conter pelo menos uma letra maiúscula") unless password.match?(/[A-Z]/)
    errors.add(:password, "deve conter pelo menos uma letra minúscula") unless password.match?(/[a-z]/)
    errors.add(:password, "deve conter pelo menos um número") unless password.match?(/\d/)
    errors.add(:password, "deve conter pelo menos um caractere especial (!@#$%^&*)") unless password.match?(/[!@#$%^&*]/)
  end
end
