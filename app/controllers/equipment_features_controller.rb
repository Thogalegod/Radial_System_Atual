class EquipmentFeaturesController < ApplicationController
  before_action :set_equipment_type, only: [:index, :new, :create]
  before_action :set_equipment_feature, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  def index
    if params[:equipment_type_id].present?
      # Listagem por tipo de equipamento específico
      @equipment_features = @equipment_type.equipment_features.ordered.with_options
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
    @equipment_types = EquipmentType.active.ordered
  end

  def update
    if @equipment_feature.update(equipment_feature_params)
      redirect_to equipment_type_equipment_features_path(@equipment_feature.equipment_type), 
                  notice: 'Característica atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    equipment_type = @equipment_feature.equipment_type
    usage_count = @equipment_feature.equipment_values.count
    
    if usage_count > 0
      redirect_to equipment_type_equipment_features_path(equipment_type), 
                  alert: "Não é possível excluir. Esta característica está sendo usada por #{usage_count} equipamento(s)."
    elsif @equipment_feature.destroy
      redirect_to equipment_type_equipment_features_path(equipment_type), 
                  notice: 'Característica removida com sucesso!'
    else
      redirect_to equipment_type_equipment_features_path(equipment_type), 
                  alert: 'Erro ao remover característica.'
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
      :name, :data_type, :unit, :description, :required, :searchable, 
      :filterable, :sortable, :default_value, :validation_rules, 
      :display_format, :color, :icon_class, :sort_order
    )
  end

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
