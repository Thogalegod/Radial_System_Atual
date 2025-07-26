class EquipmentTypesController < ApplicationController
  before_action :set_equipment_type, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  def index
    @equipment_types = EquipmentType.active.ordered.with_equipments
  end

  def show
    @equipment_count = @equipment_type.equipments.count
    @feature_count = @equipment_type.equipment_features.count
    @recent_equipments = @equipment_type.equipments.ordered_by_created.limit(5)
  end

  def new
    @equipment_type = EquipmentType.new
  end

  def create
    @equipment_type = EquipmentType.new(equipment_type_params)
    
    if @equipment_type.save
      redirect_to equipment_types_path, notice: 'Tipo de equipamento criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @equipment_type.update(equipment_type_params)
      redirect_to equipment_types_path, notice: 'Tipo de equipamento atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    equipment_count = @equipment_type.equipments.count
    
    if equipment_count > 0
      redirect_to equipment_types_path, alert: "Não é possível excluir. Existem #{equipment_count} equipamento(s) cadastrado(s) para este tipo."
    elsif @equipment_type.destroy
      redirect_to equipment_types_path, notice: 'Tipo de equipamento removido com sucesso!'
    else
      redirect_to equipment_types_path, alert: 'Erro ao remover tipo de equipamento.'
    end
  end

  def equipment_features
    @equipment_type = EquipmentType.find(params[:id])
    features = @equipment_type.equipment_features.ordered.includes(:equipment_feature_options)
    
    render json: features.map do |feature|
      {
        id: feature.id,
        name: feature.name,
        data_type: feature.data_type,
        required: feature.required,
        filterable: feature.filterable,
        searchable: feature.searchable,
        sortable: feature.sortable,
        description: feature.description,
        unit: feature.unit,
        options: feature.equipment_feature_options.active.ordered.map do |option|
          {
            id: option.id,
            value: option.value,
            label: option.label,
            color: option.color
          }
        end
      }
    end
  end

  private

  def set_equipment_type
    @equipment_type = EquipmentType.find(params[:id])
  end

  def equipment_type_params
    params.require(:equipment_type).permit(
      :name, :description, :icon_class, :primary_color, 
      :secondary_color, :accent_color, :active, :sort_order
    )
  end

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
