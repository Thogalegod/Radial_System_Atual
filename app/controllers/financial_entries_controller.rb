class FinancialEntriesController < ApplicationController
  begin
    require 'csv'
  rescue LoadError
    # CSV não disponível; exportação será desativada automaticamente
  end
  require 'bigdecimal'
  before_action :require_login
  before_action -> { require_resource_permission(:financial_entries, :read) }, only: [:index, :show]
  before_action -> { require_resource_permission(:financial_entries, :create) }, only: [:new, :create]
  before_action -> { require_resource_permission(:financial_entries, :update) }, only: [:edit, :update, :update_status]
  before_action -> { require_resource_permission(:financial_entries, :destroy) }, only: [:destroy]
  before_action :set_financial_entry, only: [:show, :edit, :update, :destroy, :update_status]

  def index
    # ---- Lógica do Dashboard ----
    @selected_month = params[:month] ? Date.parse("#{params[:month]}-01") : Date.current

    # Redirecionar para Recebimentos por padrão (apenas HTML e quando não for busca por referência)
    if request.format.html? && params[:type].blank? && params[:reference_id].blank? && params[:reference_type].blank?
      return redirect_to financial_entries_path(month: @selected_month.strftime('%Y-%m'), type: 'receivable', client_id: params[:client_id], page: params[:page], per_page: params[:per_page])
    end
    
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
      base_scope = FinancialEntry.where(reference_id: params[:reference_id], reference_type: params[:reference_type])
                                 .includes(:client)
    else
      # Caso contrário, aplicar filtro de mês
      base_scope = FinancialEntry.for_month(@selected_month).includes(:client)

      # Filtro por tipo (Recebimentos/Despesas)
      if params[:type].in?(['receivable', 'payable'])
        base_scope = base_scope.where(entry_type: params[:type])
      end

      # Filtro por cliente
      if params[:client_id].present?
        base_scope = base_scope.where(client_id: params[:client_id])
      end

      # Filtro por empresa (Fontes Energia / Aradial Equipamentos)
      if params[:company].present?
        base_scope = base_scope.where(company: params[:company])
      end

      # Filtro por situação do pagamento (layout semelhante à imagem)
      case params[:payment_state]
      when 'paid'
        base_scope = base_scope.where(status: 'paid')
      when 'not_paid'
        base_scope = base_scope.where(status: ['pending', 'overdue'])
      when 'due_today'
        base_scope = base_scope.where(due_date: Date.current, status: 'pending')
      when 'overdue'
        base_scope = base_scope.where("status = 'overdue' OR (status = 'pending' AND due_date < ?)", Date.current)
      end

      # Filtro por intervalo de datas de vencimento (aplica somente se datas válidas)
      start_date = (Date.parse(params[:start_date]) rescue nil) if params[:start_date].present?
      end_date   = (Date.parse(params[:end_date]) rescue nil)   if params[:end_date].present?
      base_scope = base_scope.where('due_date >= ?', start_date) if start_date
      base_scope = base_scope.where('due_date <= ?', end_date)   if end_date

      # Filtro por faixa de valores (aplica somente se números válidos)
      min_amount = (BigDecimal(params[:amount_min]) rescue nil) if params[:amount_min].present?
      max_amount = (BigDecimal(params[:amount_max]) rescue nil) if params[:amount_max].present?
      base_scope = base_scope.where('amount >= ?', min_amount) if min_amount
      base_scope = base_scope.where('amount <= ?', max_amount) if max_amount

      # Busca por descrição
      if params[:q].present?
        base_scope = base_scope.merge(FinancialEntry.search(params[:q]))
      end
    end

    # Ordenação padrão
    base_scope = base_scope.order(due_date: :desc)

    # Somatórios por cliente removidos (UI simplificada)

    respond_to do |format|
      format.html do
        # Paginação manual e preservação de filtros
        @page = (params[:page] || 1).to_i
        @per_page = (params[:per_page] || 25).to_i.clamp(1, 100)
        @total_count = base_scope.count
        @total_pages = (@total_count.to_f / @per_page).ceil
        @financial_entries = base_scope.offset((@page - 1) * @per_page).limit(@per_page)
        # Pré-carrega a associação polimórfica sem eager loading via joins (API Rails 7+/8)
        ActiveRecord::Associations::Preloader.new(records: @financial_entries, associations: :reference).call
      end

      if defined?(CSV)
        format.csv do
          csv_data = CSV.generate(headers: true) do |csv|
            csv << ['ID', 'Descrição', 'Tipo', 'Status', 'Vencimento', 'Pagamento', 'Valor', 'Cliente']
            base_scope.find_each do |e|
              csv << [e.id, e.description, e.entry_type, e.status, e.due_date, e.paid_date, e.amount, e.client&.display_name]
            end
          end
          send_data csv_data, filename: "financial_entries-#{Time.current.strftime('%Y%m%d%H%M%S')}.csv"
        end
      end
    end
  end

  def show
  end

  def new
    @financial_entry = FinancialEntry.new
    @financial_entry.client_id = params[:client_id] if params[:client_id].present?
    if params[:entry_type].present? && %w[receivable payable].include?(params[:entry_type])
      @financial_entry.entry_type = params[:entry_type]
    end
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
    params.require(:financial_entry).permit(:description, :amount, :due_date, :paid_date, :status, :entry_type, :notes, :reference_id, :reference_type, :client_id, :company, attachments: [])
  end
end
