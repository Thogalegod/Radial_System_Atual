class EquipmentFeatureOptionsController < ApplicationController
  before_action :set_equipment_feature, only: [:index, :new, :create]
  before_action :set_equipment_feature_option, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  def index
    @equipment_feature_options = @equipment_feature.equipment_feature_options.ordered
  end

  def show
    @equipment_feature = @equipment_feature_option.equipment_feature
    @usage_count = @equipment_feature_option.usage_count
  end

  def new
    @equipment_feature_option = @equipment_feature.equipment_feature_options.build
  end

  def create
    @equipment_feature_option = @equipment_feature.equipment_feature_options.build(equipment_feature_option_params)
    
    if @equipment_feature_option.save
      redirect_to equipment_feature_equipment_feature_options_path(@equipment_feature), 
                  notice: 'Opção criada com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @equipment_feature = @equipment_feature_option.equipment_feature
    @equipment_type = @equipment_feature.equipment_type
  end

  def update
    if @equipment_feature_option.update(equipment_feature_option_params)
      redirect_to equipment_feature_path(@equipment_feature_option.equipment_feature), 
                  notice: 'Opção atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    equipment_feature = @equipment_feature_option.equipment_feature
    usage_count = @equipment_feature_option.usage_count
    
    if usage_count > 0
      redirect_to equipment_feature_path(equipment_feature), 
                  alert: "Não é possível excluir. Esta opção está sendo usada por #{usage_count} equipamento(s)."
    elsif @equipment_feature_option.destroy
      redirect_to equipment_feature_path(equipment_feature), 
                  notice: 'Opção removida com sucesso!'
    else
      redirect_to equipment_feature_path(equipment_feature), 
                  alert: 'Erro ao remover opção.'
    end
  end

  private

  def set_equipment_feature
    @equipment_feature = EquipmentFeature.find(params[:equipment_feature_id])
  end

  def set_equipment_feature_option
    @equipment_feature_option = EquipmentFeatureOption.find(params[:id])
  end

  def equipment_feature_option_params
    params.require(:equipment_feature_option).permit(
      :value, :label, :color, :icon_class, :sort_order, :active
    )
  end

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
