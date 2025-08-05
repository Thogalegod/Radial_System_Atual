class RentalsController < ApplicationController
  before_action :require_login
  before_action -> { require_resource_permission(:rentals, :read) }, only: [:index, :show]
  before_action -> { require_resource_permission(:rentals, :create) }, only: [:new, :create]
  before_action -> { require_resource_permission(:rentals, :update) }, only: [:edit, :update]
  before_action -> { require_resource_permission(:rentals, :destroy) }, only: [:destroy]
  before_action :set_rental, only: [:show, :edit, :update, :destroy, :complete, :reactivate]

  def index
    @rentals = Rental.includes(:client, :equipments, :rental_billing_periods)
                     .order(created_at: :desc)
    
    # Filtros
    @rentals = @rentals.where(status: params[:status]) if params[:status].present?
    @rentals = @rentals.by_client(params[:client_id]) if params[:client_id].present?
    @rentals = @rentals.with_overdue_periods if params[:overdue] == 'true'
    
    # Busca
    @rentals = @rentals.search(params[:query]) if params[:query].present?
    
    # Estatísticas
    @total_rentals = Rental.count
    @active_rentals = Rental.active.count
    @overdue_rentals = Rental.with_overdue_periods.count
    @total_billing = Rental.joins(:rental_billing_periods).sum('rental_billing_periods.amount')
    
    # Para filtros
    @clients = Client.order(:name)
    @statuses = Rental.statuses.keys
  end

  def show
    @billing_periods = @rental.rental_billing_periods
                           .includes(:financial_entry)
                           .order(:start_date)
    @equipments = @rental.equipments.includes(:equipment_type)
  end

  def new
    @rental = Rental.new
    @clients = Client.order(:name)
  end

  def create
    @rental = Rental.new(rental_params)
    
    # Processar equipamentos selecionados
    if params[:equipment_ids].present?
      equipment_ids = params[:equipment_ids].reject(&:blank?)
      @rental.equipment_ids = equipment_ids if equipment_ids.any?
    end
    
    # Processar período de faturamento
    if params[:billing_period].present? && billing_period_params[:name].present?
      billing_period = @rental.rental_billing_periods.build(billing_period_params)
    end
    
    if @rental.save
      redirect_to rentals_path, notice: 'Locação criada com sucesso!'
    else
      @clients = Client.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clients = Client.order(:name)
  end

  def update
    if @rental.update(rental_params)
      redirect_to rentals_path, notice: 'Locação atualizada com sucesso!'
    else
      @clients = Client.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rental.destroy
    redirect_to rentals_path, notice: 'Locação removida com sucesso!'
  end

  def complete
    if @rental.complete!
      redirect_to rentals_path, notice: 'Locação concluída com sucesso!'
    else
      redirect_to rentals_path, alert: 'Não foi possível concluir a locação.'
    end
  end

  def reactivate
    if @rental.reactivate!
      redirect_to rentals_path, notice: 'Locação reativada com sucesso!'
    else
      redirect_to rentals_path, alert: 'Não foi possível reativar a locação.'
    end
  end

  # API endpoints para AJAX
  def status_counts
    render json: {
      total: Rental.count,
      active: Rental.active.count,
      completed: Rental.completed.count,
      overdue: Rental.with_overdue_periods.count
    }
  end

  def overdue_alerts
    overdue_rentals = Rental.with_overdue_periods.includes(:client, :rental_billing_periods)
    
    alerts = overdue_rentals.map do |rental|
      {
        id: rental.id,
        name: rental.name,
        client: rental.client.name,
        days_overdue: rental.days_overdue,
        amount_overdue: rental.amount_overdue
      }
    end
    
    render json: alerts
  end

  private

  def set_rental
    @rental = Rental.find(params[:id])
  end

  def rental_params
    params.require(:rental).permit(:name, :client_id, :status, :remessa_note)
  end

  def billing_period_params
    params.require(:billing_period).permit(:name, :amount, :start_date, :end_date)
  end
end
