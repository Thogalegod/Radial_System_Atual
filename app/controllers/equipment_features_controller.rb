class EquipmentFeaturesController < ApplicationController
  before_action :require_login
  before_action -> { require_resource_permission(:equipment_features, :read) }, only: [:index, :show]
  before_action -> { require_resource_permission(:equipment_features, :create) }, only: [:new, :create]
  before_action -> { require_resource_permission(:equipment_features, :update) }, only: [:edit, :update]
  before_action -> { require_resource_permission(:equipment_features, :destroy) }, only: [:destroy]
  before_action :set_equipment_type, only: [:index, :new, :create]
  before_action :set_equipment_feature, only: [:show, :edit, :update, :destroy]

  def index
    if params[:equipment_type_id].present?
      # Listagem por tipo de equipamento específico
      @equipment_features = @equipment_type.equipment_features.ordered.includes(:equipment_feature_options)
    else
      # Listagem geral com filtros
      @equipment_features = EquipmentFeature.includes(:equipment_type, :equipment_feature_options).all
      
      # Aplicar filtros
      @equipment_features = @equipment_features.where(equipment_type_id: params[:equipment_type_id]) if params[:equipment_type_id].present?
      @equipment_features = @equipment_features.where(data_type: params[:data_type]) if params[:data_type].present?
      @equipment_features = @equipment_features.where(required: params[:required]) if params[:required].present?
      @equipment_features = @equipment_features.where(filterable: params[:filterable]) if params[:filterable].present?
      
      # Ordenar por nome
      @equipment_features = @equipment_features.order(:name)
    end
    
    respond_to do |format|
      format.html
      format.json do
        Rails.logger.info "Enviando #{@equipment_features.count} features"
        @equipment_features.each do |feature|
          Rails.logger.info "Feature #{feature.name}: #{feature.equipment_feature_options.active.count} opções"
        end
        
        json_response = @equipment_features.map do |feature|
          feature_json = {
            id: feature.id,
            name: feature.name,
            data_type: feature.data_type,
            required: feature.required,
            filterable: feature.filterable,
            searchable: feature.searchable,
            sortable: feature.sortable,
            description: feature.description,
            unit: feature.unit,
            options: feature.equipment_feature_options.ordered.map do |option|
              {
                id: option.id,
                value: option.value,
                label: option.label,
                color: option.color
              }
            end
          }
          
          Rails.logger.info "JSON para #{feature.name}: #{feature_json[:options].length} opções"
          feature_json
        end
        
        Rails.logger.info "JSON final: #{json_response.to_json[0..200]}..."
        render json: json_response
      end
    end
  end

  def show
    @equipment_type = @equipment_feature.equipment_type
    @feature_options = @equipment_feature.equipment_feature_options.ordered
    @usage_count = @equipment_feature.equipment_values.count
  end

  def new
    if params[:equipment_type_id].present?
      @equipment_feature = @equipment_type.equipment_features.build
    else
      @equipment_feature = EquipmentFeature.new
      @equipment_types = EquipmentType.active.ordered
    end
  end

  def create
    if params[:equipment_type_id].present?
      @equipment_feature = @equipment_type.equipment_features.build(equipment_feature_params)
      
      if @equipment_feature.save
        redirect_to equipment_type_equipment_features_path(@equipment_type), 
                    notice: 'Característica criada com sucesso!'
      else
        render :new, status: :unprocessable_entity
      end
    else
      @equipment_feature = EquipmentFeature.new(equipment_feature_params)
      
      if @equipment_feature.save
        redirect_to equipment_features_path, 
                    notice: 'Característica criada com sucesso!'
      else
        @equipment_types = EquipmentType.active.ordered
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    @equipment_type = @equipment_feature.equipment_type
    @feature_options = @equipment_feature.equipment_feature_options.ordered
  end

  def update
    if @equipment_feature.update(equipment_feature_params)
      redirect_to equipment_feature_path(@equipment_feature), 
                  notice: 'Característica atualizada com sucesso!'
    else
      @equipment_type = @equipment_feature.equipment_type
      @feature_options = @equipment_feature.equipment_feature_options.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    equipment_type = @equipment_feature.equipment_type
    feature_name = @equipment_feature.name
    
    if @equipment_feature.equipment_values.any?
      redirect_to equipment_features_path, 
                  alert: "Não é possível excluir. A característica '#{feature_name}' está sendo usada por equipamentos."
    elsif @equipment_feature.destroy
      redirect_to equipment_features_path, 
                  notice: "Característica '#{feature_name}' removida com sucesso!"
    else
      redirect_to equipment_features_path, 
                  alert: "Erro ao remover característica '#{feature_name}'."
    end
  end

  private

  def set_equipment_type
    @equipment_type = EquipmentType.find(params[:equipment_type_id]) if params[:equipment_type_id].present?
  end

  def set_equipment_feature
    @equipment_feature = EquipmentFeature.find(params[:id])
  end

  def equipment_feature_params
    params.require(:equipment_feature).permit(
      :name, :data_type, :required, :filterable, :searchable, 
      :sortable, :description, :unit, :equipment_type_id
    )
  end
end
