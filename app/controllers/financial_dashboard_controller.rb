class FinancialDashboardController < ApplicationController
  before_action :require_login
  before_action -> { require_resource_permission(:financial_entries, :read) }

  def index
    @selected_month = params[:month] ? Date.parse("#{params[:month]}-01") : Date.current
    
    # KPIs Principais
    @kpis = calculate_main_kpis(@selected_month)
    
    # Dados para Gráficos
    @chart_data = prepare_chart_data(@selected_month)
    
    # Alertas e Notificações
    @alerts = generate_financial_alerts
    
    # Top Performers
    @top_clients = top_performing_clients(@selected_month)
    @overdue_entries = overdue_financial_entries
    
    # Projeções
    @projections = calculate_projections(@selected_month)
  end

  private

  def calculate_main_kpis(month)
    monthly_entries = FinancialEntry.for_month(month)
    
    {
      total_receivables: monthly_entries.receivable.sum(:amount),
      total_payables: monthly_entries.payable.sum(:amount),
      paid_receivables: monthly_entries.receivable.paid.sum(:amount),
      paid_payables: monthly_entries.payable.paid.sum(:amount),
      pending_receivables: monthly_entries.receivable.pending.sum(:amount),
      pending_payables: monthly_entries.payable.pending.sum(:amount),
      overdue_receivables: monthly_entries.receivable.overdue.sum(:amount),
      overdue_payables: monthly_entries.payable.overdue.sum(:amount),
      net_cash_flow: monthly_entries.receivable.paid.sum(:amount) - monthly_entries.payable.paid.sum(:amount),
      collection_rate: calculate_collection_rate(monthly_entries),
      days_sales_outstanding: calculate_dso(monthly_entries.receivable)
    }
  end

  def prepare_chart_data(month)
    monthly_entries = FinancialEntry.for_month(month)
    
    {
      daily_cash_flow: monthly_entries.group_by_day(:due_date).sum(:amount),
      receivables_by_status: monthly_entries.receivable.group(:status).sum(:amount),
      payables_by_status: monthly_entries.payable.group(:status).sum(:amount),
      monthly_trend: FinancialEntry.group_by_month(:due_date, last: 12).sum(:amount)
    }
  end

  def generate_financial_alerts
    alerts = []
    
    # Alertas de vencimento
    overdue_entries = FinancialEntry.overdue.includes(:reference)
    if overdue_entries.any?
      alerts << {
        type: 'warning',
        title: 'Pagamentos Vencidos',
        message: "#{overdue_entries.count} lançamento(s) vencido(s)",
        amount: overdue_entries.sum(:amount),
        link: financial_entries_path(overdue: true)
      }
    end
    
    # Alertas de baixa taxa de recebimento
    current_month = Date.current.beginning_of_month
    monthly_receivables = FinancialEntry.receivable.for_month(current_month)
    collection_rate = calculate_collection_rate(monthly_receivables)
    
    if collection_rate < 80
      alerts << {
        type: 'danger',
        title: 'Taxa de Recebimento Baixa',
        message: "#{collection_rate.round(1)}% de recebimento este mês",
        link: financial_entries_path(month: current_month.strftime('%Y-%m'))
      }
    end
    
    alerts
  end

  def top_performing_clients(month)
    Rental.joins(:rental_billing_periods)
          .joins('INNER JOIN financial_entries ON financial_entries.reference_id = rental_billing_periods.id')
          .where('financial_entries.due_date BETWEEN ? AND ?', month.beginning_of_month, month.end_of_month)
          .group('rentals.client_id')
          .sum('financial_entries.amount')
          .sort_by { |_, amount| -amount }
          .first(5)
          .map { |client_id, amount| [Client.find(client_id), amount] }
  end

  def overdue_financial_entries
    FinancialEntry.overdue
                  .includes(:reference)
                  .order(:due_date)
                  .limit(10)
  end

  def calculate_projections(month)
    # Projeção baseada no histórico dos últimos 3 meses
    last_3_months = (month - 3.months)..(month - 1.month)
    historical_data = FinancialEntry.where(due_date: last_3_months)
                                   .group_by_month(:due_date)
                                   .sum(:amount)
    
    avg_monthly = historical_data.values.sum / historical_data.size rescue 0
    
    {
      next_month_projection: avg_monthly,
      trend: calculate_trend(historical_data),
      confidence_level: calculate_confidence_level(historical_data)
    }
  end

  def calculate_collection_rate(entries)
    total = entries.receivable.sum(:amount)
    paid = entries.receivable.paid.sum(:amount)
    
    return 0 if total.zero?
    (paid / total) * 100
  end

  def calculate_dso(receivables)
    return 0 if receivables.empty?
    
    total_receivables = receivables.sum(:amount)
    avg_daily_sales = total_receivables / 30 # Assumindo 30 dias
    
    return 0 if avg_daily_sales.zero?
    
    overdue_amount = receivables.overdue.sum(:amount)
    (overdue_amount / avg_daily_sales).round
  end

  def calculate_trend(historical_data)
    return 'stable' if historical_data.size < 2
    
    values = historical_data.values
    first_half = values.first(values.size / 2).sum
    second_half = values.last(values.size / 2).sum
    
    if second_half > first_half * 1.1
      'increasing'
    elsif second_half < first_half * 0.9
      'decreasing'
    else
      'stable'
    end
  end

  def calculate_confidence_level(historical_data)
    return 'low' if historical_data.size < 3
    
    variance = calculate_variance(historical_data.values)
    avg = historical_data.values.sum / historical_data.size
    
    cv = (Math.sqrt(variance) / avg) * 100
    
    case cv
    when 0..15 then 'high'
    when 15..30 then 'medium'
    else 'low'
    end
  end

  def calculate_variance(values)
    avg = values.sum / values.size
    values.sum { |v| (v - avg) ** 2 } / values.size
  end
end
