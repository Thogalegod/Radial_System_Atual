class EquipmentsController < ApplicationController
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]
  before_action :set_equipment_types, only: [:index, :new, :create, :edit, :update]
  before_action :require_login

  def index
    @equipments = apply_filters_and_sorting
    @equipment_types = EquipmentType.active.ordered
    
    # Definir tipo de equipamento se filtrado por tipo
    if params[:type].present?
      @equipment_type = EquipmentType.find(params[:type])
    end
  end

  def filter
    @equipments = apply_filters_and_sorting
    
    render json: {
      equipments: @equipments.map do |equipment|
        {
          id: equipment.id,
          serial_number: equipment.serial_number,
          equipment_type: equipment.equipment_type.name,
          status: equipment.status_display,
          status_color: equipment.status_color,
          location: equipment.location,
          acquisition_date: equipment.acquisition_date&.strftime('%d/%m/%Y'),
          acquisition_price: equipment.formatted_acquisition_price,
          bandeira: equipment.bandeira,
          feature_values: equipment.feature_values.transform_values(&:formatted_value),
          created_at: equipment.created_at.strftime('%d/%m/%Y'),
          updated_at: equipment.updated_at.strftime('%d/%m/%Y')
        }
      end,
      total_count: @equipments.count
    }
  end

  def show
    @feature_values = @equipment.feature_values
    @equipment_type = @equipment.equipment_type
  end

  def new
    @equipment = Equipment.new
    @equipment_type = EquipmentType.find(params[:equipment_type_id]) if params[:equipment_type_id]
  end

  def create
    # Separar fotos das outras atualizações
    photos_to_add = params[:equipment][:photos] if params[:equipment][:photos].present?
    
    # Remover fotos do params para evitar problemas
    create_params = equipment_params.except(:photos)
    
    @equipment = Equipment.new(create_params)
    
    if @equipment.save
      # Adicionar fotos (se houver)
      if photos_to_add.present?
        photos_to_add.each do |photo|
          @equipment.photos.attach(photo)
        end
      end
      
      # Salvar valores das características
      save_feature_values
      
      redirect_to equipments_path, notice: 'Equipamento cadastrado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @feature_values = @equipment.feature_values
    @equipment_features = @equipment.equipment_features.ordered.includes(:equipment_feature_options)
  end

  def update
    # Verificar se o tipo de equipamento está sendo alterado
    if params[:equipment][:equipment_type_id].present? && 
       params[:equipment][:equipment_type_id].to_i != @equipment.equipment_type_id
      @equipment.errors.add(:equipment_type_id, "não pode ser alterado após a criação do equipamento")
      @feature_values = @equipment.feature_values
      @equipment_features = @equipment.equipment_features.ordered.includes(:equipment_feature_options)
      render :edit, status: :unprocessable_entity
      return
    end
    
    # Separar fotos das outras atualizações
    photos_to_add = params[:equipment][:photos] if params[:equipment][:photos].present?
    
    # Remover fotos do params para evitar substituição
    update_params = equipment_params.except(:photos)
    
    if @equipment.update(update_params)
      # Adicionar novas fotos (se houver)
      if photos_to_add.present?
        photos_to_add.each do |photo|
          @equipment.photos.attach(photo)
        end
      end
      
      # Processar remoção de fotos
      if params[:remove_photos].present?
        params[:remove_photos].each do |photo_index|
          photo = @equipment.photos[photo_index.to_i]
          photo.purge if photo
        end
      end
      
      # Atualizar valores das características
      save_feature_values
      
      redirect_to equipments_path, notice: 'Equipamento atualizado com sucesso!'
    else
      # Preparar variáveis necessárias para re-renderizar a view
      @feature_values = @equipment.feature_values
      @equipment_features = @equipment.equipment_features.ordered.includes(:equipment_feature_options)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    serial_number = @equipment.serial_number
    
    if @equipment.destroy
      redirect_to equipments_path, notice: "Equipamento #{serial_number} removido com sucesso!"
    else
      redirect_to equipments_path, alert: "Erro ao remover equipamento: #{@equipment.errors.full_messages.join(', ')}"
    end
  end

  def export_csv
    @equipments = apply_filters_and_sorting
    
    respond_to do |format|
      format.csv do
        send_data generate_csv, 
          filename: "equipamentos_#{Date.current.strftime('%Y%m%d')}.csv",
          type: 'text/csv; charset=utf-8'
      end
    end
  end

  def select_type
    # Esta action renderiza a tela de seleção de tipo
  end

  def photos
    @equipment = Equipment.find(params[:id])
    photo_urls = @equipment.photos.map { |photo| url_for(photo) }
    
    render json: {
      photos: photo_urls,
      count: photo_urls.length
    }
  end

  private

  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def set_equipment_types
    @equipment_types = EquipmentType.active.ordered
  end

  def equipment_params
    params.require(:equipment).permit(
      :serial_number, :equipment_type_id, :notes, :location,
      :acquisition_date, :acquisition_price, :bandeira, photos: []
    )
  end

  def save_feature_values
    return unless params[:feature_values]

    params[:feature_values].each do |feature_name, value|
      @equipment.set_feature_value(feature_name, value)
    end
  end

  def apply_filters_and_sorting
    equipments = Equipment.includes(:equipment_type, :equipment_values, :equipment_features)

    # Filtros básicos
    equipments = equipments.by_type(params[:type]) if params[:type].present?
    equipments = equipments.by_type(params[:equipment_type_id]) if params[:equipment_type_id].present?
    equipments = equipments.where(location: params[:location]) if params[:location].present?
    equipments = equipments.where(bandeira: params[:bandeira]) if params[:bandeira].present?
    
    # Filtros de texto
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      equipments = equipments.where(
        "serial_number ILIKE ? OR notes ILIKE ?",
        search_term, search_term
      )
    end

    # Filtros especiais
    equipments = equipments.with_notes if params[:with_notes] == 'true'
    equipments = equipments.without_notes if params[:no_notes] == 'true'
    equipments = equipments.where(notes: [nil, '']) if params[:no_notes] == 'true'

    # Filtros de data
    if params[:acquisition_date_from].present?
      equipments = equipments.where('acquisition_date >= ?', params[:acquisition_date_from])
    end
    if params[:acquisition_date_to].present?
      equipments = equipments.where('acquisition_date <= ?', params[:acquisition_date_to])
    end

    # Filtros de características
    if params[:feature_filters].present?
      params[:feature_filters].each do |feature_name, value|
        next if value.blank?
        
        feature = EquipmentFeature.joins(:equipment_type)
                                 .where(equipment_features: { name: feature_name })
                                 .first
        
        if feature
          equipments = equipments.joins(:equipment_values)
                                .where(equipment_values: { 
                                  equipment_feature: feature, 
                                  value: value 
                                })
        end
      end
    end

    # Ordenação
    sort_field = params[:sort_field] || 'serial_number'
    sort_direction = params[:sort_direction] || 'asc'

    case sort_field
    when 'serial_number'
      equipments = sort_direction == 'desc' ? equipments.order(serial_number: :desc) : equipments.order(:serial_number)
    when 'equipment_type'
      equipments = equipments.joins(:equipment_type)
      equipments = sort_direction == 'desc' ? equipments.order('equipment_types.name DESC') : equipments.order('equipment_types.name')
    when 'location'
      equipments = sort_direction == 'desc' ? equipments.order(location: :desc) : equipments.order(:location)
    when 'bandeira'
      equipments = sort_direction == 'desc' ? equipments.order(bandeira: :desc) : equipments.order(:bandeira)
    when 'created_at'
      equipments = sort_direction == 'desc' ? equipments.order(created_at: :desc) : equipments.order(:created_at)
    when 'updated_at'
      equipments = sort_direction == 'desc' ? equipments.order(updated_at: :desc) : equipments.order(:updated_at)
    else
      equipments = equipments.order(:serial_number)
    end

    equipments
  end

  def generate_csv
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      # Headers básicos
      headers = [
        'Número de Série',
        'Tipo de Equipamento',
        'Status',
        'Localização',
        'Fabricante',
        'Modelo',
        'Data de Instalação',
        'Última Manutenção',
        'Próxima Manutenção',
        'Observações'
      ]
      
      # Headers dinâmicos para características
      all_features = EquipmentFeature.joins(:equipment_type)
                                   .where(equipment_types: { id: @equipments.joins(:equipment_type).distinct.pluck(:equipment_type_id) })
                                   .distinct
                                   .ordered
      
      all_features.each do |feature|
        headers << feature.name
      end
      
      csv << headers
      
      # Dados
      @equipments.each do |equipment|
        row = [
          equipment.serial_number,
          equipment.equipment_type.name,
          equipment.status_display,
          equipment.location,
          equipment.manufacturer,
          equipment.model,
          equipment.installation_date&.strftime('%d/%m/%Y'),
          equipment.last_maintenance_date&.strftime('%d/%m/%Y'),
          equipment.next_maintenance_date&.strftime('%d/%m/%Y'),
          equipment.notes
        ]
        
        # Valores das características
        all_features.each do |feature|
          value = equipment.feature_value(feature.name)
          row << (value&.formatted_value || '')
        end
        
        csv << row
      end
    end
  end

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
