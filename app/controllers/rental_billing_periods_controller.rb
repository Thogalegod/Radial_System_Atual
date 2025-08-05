class RentalBillingPeriodsController < ApplicationController
  before_action :require_login
  before_action -> { require_resource_permission(:rental_billing_periods, :read) }, only: [:index, :show, :receipt, :receipt_pdf]
  before_action -> { require_resource_permission(:rental_billing_periods, :create) }, only: [:new, :create]
  before_action -> { require_resource_permission(:rental_billing_periods, :update) }, only: [:edit, :update]
  before_action -> { require_resource_permission(:rental_billing_periods, :destroy) }, only: [:destroy]
  before_action :set_rental
  before_action :set_billing_period, only: [:show, :edit, :update, :destroy, :receipt, :receipt_pdf, :regenerate_financial_entry]

  def index
    @billing_periods = @rental.rental_billing_periods
                           .includes(:financial_entry)
                           .ordered_by_date
  end

  def show
  end

  def new
    @billing_period = @rental.rental_billing_periods.build
  end

  def create
    @billing_period = @rental.rental_billing_periods.build(billing_period_params)

    if @billing_period.save
      redirect_to rental_rental_billing_periods_path(@rental), notice: 'Período de faturamento criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @billing_period.update(billing_period_params)
      redirect_to rental_rental_billing_periods_path(@rental), notice: 'Período de faturamento atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @billing_period.destroy
    redirect_to rental_rental_billing_periods_path(@rental), notice: 'Período de faturamento removido com sucesso.'
  end

  def receipt
    # Renderiza o recibo em HTML
  end

  def receipt_pdf
    # Gera e faz download do PDF
    respond_to do |format|
      format.pdf do
        render pdf: "recibo_#{@rental.generate_debit_note_number(@billing_period)}",
               template: "rental_billing_periods/receipt",
               layout: false,
               disposition: "attachment",
               page_size: "A4",
               orientation: "Portrait",
               margin: {
                 top: 5,
                 bottom: 5,
                 left: 5,
                 right: 5
               }
      end
    end
  end

  def regenerate_financial_entry
    if @billing_period.regenerate_financial_entry
      redirect_to rental_rental_billing_periods_path(@rental), notice: 'Lançamento financeiro regenerado com sucesso!'
    else
      redirect_to rental_rental_billing_periods_path(@rental), alert: 'Erro ao regenerar lançamento financeiro.'
    end
  end

  private

  def set_rental
    @rental = Rental.find(params[:rental_id])
  end

  def set_billing_period
    @billing_period = @rental.rental_billing_periods.find(params[:id])
  end

  def billing_period_params
    params.require(:rental_billing_period).permit(:name, :start_date, :end_date, :amount, :client_order, :observations)
  end
end
