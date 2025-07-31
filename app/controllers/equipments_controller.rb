class EquipmentsController < ApplicationController
  before_action :require_login
  before_action :require_resource_permission, :equipments, :read, only: [:index, :show, :filter, :photos]
  before_action :require_resource_permission, :equipments, :create, only: [:new, :create]
  before_action :require_resource_permission, :equipments, :update, only: [:edit, :update]
  before_action :require_resource_permission, :equipments, :destroy, only: [:destroy]
  before_action :require_resource_permission, :equipments, :export, only: [:export_csv]
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]
  before_action :set_equipment_types, only: [:index, :new, :create, :edit, :update]

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
      
      # Salvar valores das características
      save_feature_values
      
      redirect_to equipments_path, notice: 'Equipamento atualizado com sucesso!'
    else
      @feature_values = @equipment.feature_values
      @equipment_features = @equipment.equipment_features.ordered.includes(:equipment_feature_options)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    serial_number = @equipment.serial_number
    @equipment.destroy
    redirect_to equipments_path, notice: "Equipamento #{serial_number} removido com sucesso!"
  end

  def export_csv
    @equipments = apply_filters_and_sorting
    csv_data = generate_csv(@equipments)
    
    send_data csv_data, 
              filename: "equipamentos_#{Date.current.strftime('%Y%m%d')}.csv",
              type: 'text/csv; charset=utf-8; header=present'
  end

  def select_type
    @equipment_types = EquipmentType.active.ordered
  end

  def photos
    @equipment = Equipment.find(params[:id])
    render json: {
      photos: @equipment.photos.map do |photo|
        {
          id: photo.id,
          url: rails_blob_url(photo),
          filename: photo.filename.to_s
        }
      end
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
      :serial_number, :equipment_type_id, :status, :location, 
      :acquisition_date, :acquisition_price, :bandeira, :notes, :photos
    )
  end

  def save_feature_values
    return unless params[:feature_values]
    
    params[:feature_values].each do |feature_id, value|
      next if value.blank?
      
      equipment_value = @equipment.equipment_values.find_or_initialize_by(equipment_feature_id: feature_id)
      equipment_value.value = value
      equipment_value.save
    end
  end

  def apply_filters_and_sorting
    equipments = Equipment.includes(:equipment_type, :equipment_values, :equipment_features)
    
    # Filtro por tipo de equipamento
    if params[:equipment_type_id].present?
      equipments = equipments.where(equipment_type_id: params[:equipment_type_id])
    end
    
    # Filtro por status
    if params[:status].present?
      equipments = equipments.where(status: params[:status])
    end
    
    # Filtro por localização
    if params[:location].present?
      equipments = equipments.where('location ILIKE ?', "%#{params[:location]}%")
    end
    
    # Filtro por número de série
    if params[:serial_number].present?
      equipments = equipments.where('serial_number ILIKE ?', "%#{params[:serial_number]}%")
    end
    
    # Filtro por bandeira
    if params[:bandeira].present?
      equipments = equipments.where(bandeira: params[:bandeira])
    end
    
    # Filtro por data de aquisição
    if params[:acquisition_date_from].present?
      equipments = equipments.where('acquisition_date >= ?', Date.parse(params[:acquisition_date_from]))
    end
    
    if params[:acquisition_date_to].present?
      equipments = equipments.where('acquisition_date <= ?', Date.parse(params[:acquisition_date_to]))
    end
    
    # Filtro por preço de aquisição
    if params[:acquisition_price_min].present?
      equipments = equipments.where('acquisition_price >= ?', params[:acquisition_price_min].to_f)
    end
    
    if params[:acquisition_price_max].present?
      equipments = equipments.where('acquisition_price <= ?', params[:acquisition_price_max].to_f)
    end
    
    # Ordenação
    sort_by = params[:sort_by] || 'created_at'
    sort_direction = params[:sort_direction] || 'desc'
    
    case sort_by
    when 'serial_number'
      equipments = equipments.order("serial_number #{sort_direction}")
    when 'equipment_type'
      equipments = equipments.joins(:equipment_type).order("equipment_types.name #{sort_direction}")
    when 'status'
      equipments = equipments.order("status #{sort_direction}")
    when 'location'
      equipments = equipments.order("location #{sort_direction}")
    when 'acquisition_date'
      equipments = equipments.order("acquisition_date #{sort_direction}")
    when 'acquisition_price'
      equipments = equipments.order("acquisition_price #{sort_direction}")
    when 'bandeira'
      equipments = equipments.order("bandeira #{sort_direction}")
    else
      equipments = equipments.order("created_at #{sort_direction}")
    end
    
    equipments
  end

  def generate_csv(equipments)
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      csv << [
        'Número de Série',
        'Tipo de Equipamento',
        'Status',
        'Localização',
        'Data de Aquisição',
        'Preço de Aquisição',
        'Bandeira',
        'Observações',
        'Data de Criação',
        'Última Atualização'
      ]
      
      equipments.each do |equipment|
        csv << [
          equipment.serial_number,
          equipment.equipment_type.name,
          equipment.status_display,
          equipment.location,
          equipment.acquisition_date&.strftime('%d/%m/%Y'),
          equipment.formatted_acquisition_price,
          equipment.bandeira,
          equipment.notes,
          equipment.created_at.strftime('%d/%m/%Y'),
          equipment.updated_at.strftime('%d/%m/%Y')
        ]
      end
    end
  end
end
