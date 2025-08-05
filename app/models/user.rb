class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "deve ser um email válido" }
  validates :role, presence: true, inclusion: { in: %w[admin manager operator viewer] }
  
  # Validação de senha forte
  validate :password_strength, if: :password_required?
  
  # Roles disponíveis
  ROLES = %w[admin manager operator viewer].freeze
  
  # Permissões por role
  PERMISSIONS = {
    admin: %w[all],
    manager: %w[
      users_read rentals_all equipments_all clients_all reports_all
      dashboard_read equipment_types_all equipment_features_all equipment_feature_options_all
      rental_billing_periods_all rental_equipments_all financial_entries_all
    ],
    operator: %w[
      rentals_read rentals_create equipments_read clients_read
      dashboard_read equipment_types_read equipment_features_read
      rental_billing_periods_read rental_equipments_create rental_equipments_destroy
      financial_entries_read
    ],
    viewer: %w[
      rentals_read equipments_read clients_read
      dashboard_read equipment_types_read equipment_features_read
      rental_billing_periods_read financial_entries_read
    ]
  }.freeze
  
  # Métodos de verificação de role
  def admin?
    role == 'admin'
  end
  
  def manager?
    role == 'manager'
  end
  
  def operator?
    role == 'operator'
  end
  
  def viewer?
    role == 'viewer'
  end
  
  # Métodos de verificação de permissões
  def can?(action)
    return true if admin?
    
    user_permissions = PERMISSIONS[role.to_sym] || []
    user_permissions.include?('all') || user_permissions.include?(action.to_s)
  end
  
  def can_access?(resource, action = nil)
    permission = action ? "#{resource}_#{action}" : "#{resource}_all"
    can?(permission)
  end
  
  # Métodos específicos de permissão
  def can_manage_users?
    can?('users_all') || admin?
  end
  
  def can_manage_rentals?
    can?('rentals_all') || admin?
  end
  
  def can_create_rentals?
    can?('rentals_create') || can_manage_rentals?
  end
  
  def can_manage_equipments?
    can?('equipments_all') || admin?
  end
  
  def can_manage_clients?
    can?('clients_all') || admin?
  end
  
  def can_view_reports?
    can?('reports_all') || admin?
  end
  
  def can_manage_equipment_types?
    can?('equipment_types_all') || admin?
  end
  
  def can_manage_equipment_features?
    can?('equipment_features_all') || admin?
  end
  
  def can_manage_equipment_feature_options?
    can?('equipment_feature_options_all') || admin?
  end
  
  def can_manage_rental_billing_periods?
    can?('rental_billing_periods_all') || admin?
  end
  
  def can_manage_rental_equipments?
    can?('rental_equipments_all') || admin?
  end

  def can_manage_financial_entries?
    can?('financial_entries_all') || admin?
  end
  
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
