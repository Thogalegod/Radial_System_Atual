class EquipmentController < ApplicationController
  before_action :require_login
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  def index
    @equipment = Equipment.includes(:category).all.order(:number)
  end

  def show
  end

  def new
    @equipment = Equipment.new
  end

  def create
    @equipment = Equipment.new(equipment_params)
    if @equipment.save
      redirect_to equipment_index_path, notice: 'Equipamento cadastrado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @equipment.update(equipment_params)
      redirect_to equipment_index_path, notice: 'Equipamento atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @equipment.destroy
    redirect_to equipment_index_path, notice: 'Equipamento removido com sucesso!'
  end

  private

  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def equipment_params
    params.require(:equipment).permit(:number, :status, :power, :voltage, :location, :category_id)
  end

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
