class DashboardController < ApplicationController
  before_action :require_login
  before_action -> { require_resource_permission(:dashboard, :read) }

  def index
    # Estatísticas gerais
    @total_equipment_types = EquipmentType.active.count
    @total_equipments = Equipment.count
    @total_features = EquipmentFeature.count
    @total_options = EquipmentFeatureOption.count

    # Estatísticas por status (calculadas dinamicamente)
    @equipments_by_status = {
      'em_estoque' => Equipment.em_estoque.count,
      'alugado' => Equipment.alugado.count
    }
    
    @equipments_by_type = Equipment.joins(:equipment_type)
                                  .group('equipment_types.name')
                                  .count

    # Equipamentos recentes
    @recent_equipments = Equipment.includes(:equipment_type)
                                 .ordered_by_created
                                 .limit(10)

    # Equipamentos alugados
    @alugados_equipments = Equipment.alugado
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
end
