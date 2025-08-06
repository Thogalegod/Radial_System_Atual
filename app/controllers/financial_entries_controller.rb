class FinancialEntriesController < ApplicationController
  before_action :require_login
  before_action -> { require_resource_permission(:financial_entries, :read) }, only: [:index, :show]
  before_action -> { require_resource_permission(:financial_entries, :create) }, only: [:new, :create]
  before_action -> { require_resource_permission(:financial_entries, :update) }, only: [:edit, :update, :update_status]
  before_action -> { require_resource_permission(:financial_entries, :destroy) }, only: [:destroy]
  before_action :set_financial_entry, only: [:show, :edit, :update, :destroy, :update_status]

  def index
    # ---- Lógica do Dashboard ----
    @selected_month = params[:month] ? Date.parse("#{params[:month]}-01") : Date.current
    
    # KPIs do Mês
    monthly_entries = FinancialEntry.for_month(@selected_month)
    
    # Recebimentos
    @receivables_total = monthly_entries.receivable.sum(:amount)
    @receivables_paid = monthly_entries.receivable.paid.sum(:amount)
    @receivable_progress = @receivables_total.zero? ? 0 : (@receivables_paid / @receivables_total) * 100
    
    # Despesas
    @payables_total = monthly_entries.payable.sum(:amount)
    @payables_paid = monthly_entries.payable.paid.sum(:amount)
    @payable_progress = @payables_total.zero? ? 0 : (@payables_paid / @payables_total) * 100

    # Resultado Previsto
    @expected_result = @receivables_total - @payables_total

    # ---- Lógica da Tabela de Transações ----
    if params[:reference_id].present? && params[:reference_type].present?
      # Se há parâmetros de referência, mostrar todos os lançamentos dessa referência
      @financial_entries = FinancialEntry.where(reference_id: params[:reference_id], reference_type: params[:reference_type])
                                       .includes(:reference)
                                       .order(due_date: :desc)
    else
      # Caso contrário, aplicar filtro de mês
      @financial_entries = FinancialEntry.for_month(@selected_month).includes(:reference).order(due_date: :desc)
      
      # Filtro por tipo (Recebimentos/Despesas)
      if params[:type].in?(['receivable', 'payable'])
        @financial_entries = @financial_entries.where(entry_type: params[:type])
      end
    end
  end

  def show
  end

  def new
    @financial_entry = FinancialEntry.new
  end

  def create
    @financial_entry = FinancialEntry.new(financial_entry_params)
    
    if @financial_entry.save
      redirect_to financial_entries_path, notice: 'Lançamento financeiro criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @financial_entry.update(financial_entry_params)
      redirect_to financial_entries_path, notice: 'Lançamento financeiro atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_status
    new_status = @financial_entry.is_paid? ? 'pending' : 'paid'
    
    # Se está mudando para PAGO, definir a data de pagamento
    if new_status == 'paid' && @financial_entry.status != 'paid'
      paid_date = params[:paid_date].present? ? Date.parse(params[:paid_date]) : Date.current
      if @financial_entry.update(status: new_status, paid_date: paid_date)
        redirect_to financial_entries_path(month: params[:month], type: params[:type]), notice: 'Status atualizado para PAGO.'
      else
        redirect_to financial_entries_path, alert: 'Não foi possível atualizar o status.'
      end
    else
      # Se está mudando para PENDENTE, limpar a data de pagamento
      if @financial_entry.update(status: new_status, paid_date: nil)
        redirect_to financial_entries_path(month: params[:month], type: params[:type]), notice: 'Status atualizado para PENDENTE.'
      else
        redirect_to financial_entries_path, alert: 'Não foi possível atualizar o status.'
      end
    end
  end

  def destroy
    @financial_entry.destroy
    redirect_to financial_entries_path, notice: 'Lançamento financeiro removido com sucesso!'
  end

  private

  def set_financial_entry
    @financial_entry = FinancialEntry.find(params[:id])
  end

  def financial_entry_params
    params.require(:financial_entry).permit(:description, :amount, :due_date, :paid_date, :status, :entry_type, :notes, :reference_id, :reference_type)
  end
end
