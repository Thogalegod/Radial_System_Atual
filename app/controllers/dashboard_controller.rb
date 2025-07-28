class DashboardController < ApplicationController
  before_action :require_login

  def index
    # Estatísticas gerais
    @total_equipment_types = EquipmentType.active.count
    @total_equipments = Equipment.count
    @total_features = EquipmentFeature.count
    @total_options = EquipmentFeatureOption.count

    # Estatísticas por status
    @equipments_by_status = Equipment.group(:status).count
    @equipments_by_type = Equipment.joins(:equipment_type)
                                  .group('equipment_types.name')
                                  .count

    # Equipamentos recentes
    @recent_equipments = Equipment.includes(:equipment_type)
                                 .ordered_by_created
                                 .limit(10)

    # Equipamentos alugados
    @alugados_equipments = Equipment.where(status: 'alugado')
                                   .includes(:equipment_type)
                                   .limit(5)

    # Equipamentos por bandeira
    @equipments_by_bandeira = Equipment.where.not(bandeira: [nil, ''])
                                      .group(:bandeira)
                                      .count

    # Tipos de equipamento mais populares
    @popular_types = EquipmentType.joins(:equipments)
                                 .group('equipment_types.id, equipment_types.name')
                                 .order('COUNT(equipments.id) DESC')
                                 .limit(5)

    # Características mais usadas
    @popular_features = EquipmentFeature.joins(:equipment_values)
                                       .group('equipment_features.id, equipment_features.name')
                                       .order('COUNT(equipment_values.id) DESC')
                                       .limit(5)
  end

  private

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
