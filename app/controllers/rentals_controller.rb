class RentalsController < ApplicationController
  before_action :set_rental, only: [:show, :edit, :update, :destroy, :complete]

  def index
    @rentals = Rental.with_equipments.recent
  end

  def show
  end

  def new
    @rental = Rental.new
    @clients = Client.order(:name)
  end

  def create
    @rental = Rental.new(rental_params)
    @rental.status = 'ativo' # Define status ativo automaticamente

    if @rental.save
      redirect_to @rental, notice: 'Locação criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clients = Client.order(:name)
  end

  def update
    @clients = Client.order(:name)
    
    if @rental.update(rental_params)
      redirect_to @rental, notice: 'Locação atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rental.destroy
    redirect_to rentals_url, notice: 'Locação excluída com sucesso.'
  end

  def complete
    if @rental.complete!
      redirect_to @rental, notice: 'Locação concluída com sucesso!'
    else
      redirect_to @rental, alert: 'Não é possível concluir esta locação. Verifique se há equipamentos alocados.'
    end
  end

  private

  def set_rental
    @rental = Rental.find(params[:id])
  end

  def rental_params
    params.require(:rental).permit(:name, :status, :client_id, :remessa_note)
  end
end
