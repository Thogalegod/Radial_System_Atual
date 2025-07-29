class RentalsController < ApplicationController
  before_action :set_rental, only: [:show, :edit, :update, :destroy]

  def index
    @rentals = Rental.includes(:client).order(created_at: :desc)
  end

  def show
  end

  def new
    @rental = Rental.new
    @clients = Client.order(:name)
  end

  def create
    @rental = Rental.new(rental_params)
    @clients = Client.order(:name)

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

  private

  def set_rental
    @rental = Rental.find(params[:id])
  end

  def rental_params
    params.require(:rental).permit(:name, :start_date, :end_date, :status, :client_id)
  end
end
