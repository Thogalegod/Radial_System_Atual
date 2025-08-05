class RentalEquipmentsController < ApplicationController
  before_action :require_login
  before_action -> { require_resource_permission(:rental_equipments, :read) }, only: [:index]
  before_action -> { require_resource_permission(:rental_equipments, :create) }, only: [:create]
  before_action -> { require_resource_permission(:rental_equipments, :destroy) }, only: [:destroy]
  before_action :set_rental
  before_action :set_equipment, only: [:destroy]

  def index
    @rental_equipments = @rental.rental_equipments.includes(:equipment)
    @available_equipments = Equipment.available_for_rental.includes(:equipment_type)
  end

  def create
    @equipment = Equipment.find(params[:equipment_id])
    
    if @rental.add_equipment(@equipment)
      redirect_to rental_rental_equipments_path(@rental), notice: 'Equipamento adicionado com sucesso.'
    else
      redirect_to rental_rental_equipments_path(@rental), alert: 'Equipamento já está em uma locação ativa.'
    end
  end

  def destroy
    if @rental.remove_equipment(@equipment)
      redirect_to rental_rental_equipments_path(@rental), notice: 'Equipamento removido com sucesso.'
    else
      redirect_to rental_rental_equipments_path(@rental), alert: 'Erro ao remover equipamento.'
    end
  end

  private

  def set_rental
    @rental = Rental.find(params[:rental_id])
  end

  def set_equipment
    @equipment = Equipment.find(params[:id])
  end
end
