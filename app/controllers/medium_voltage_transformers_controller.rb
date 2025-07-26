class MediumVoltageTransformersController < ApplicationController
  def index
    @medium_voltage_transformers = apply_filters_and_sorting
  end

  def filter
    @medium_voltage_transformers = apply_filters_and_sorting
    render json: {
      transformers: @medium_voltage_transformers.map do |transformer|
        {
          id: transformer.id,
          serial_number: transformer.serial_number,
          voltage_display: transformer.voltage_display,
          power_display: transformer.power_display,
          location_display: transformer.location_display,
          status_display: transformer.status_display,
          cooling_display: transformer.cooling_display,
          flag_display: transformer.flag_display,
          installation_display: transformer.installation_display,
          location_color: transformer.location&.color,
          status_color: transformer.status&.color,
          power_color: transformer.power_option&.color,
          cooling_color: transformer.cooling_option&.color,
          flag_color: transformer.flag_option&.color,
          installation_color: transformer.installation_option&.color,
          bt_color: transformer.bt_option&.color
        }
      end,
      total_count: @medium_voltage_transformers.count
    }
  end

  def show
    @medium_voltage_transformer = MediumVoltageTransformer.find(params[:id])
  end

  def new
    @medium_voltage_transformer = MediumVoltageTransformer.new
  end

  def create
    @medium_voltage_transformer = MediumVoltageTransformer.new(medium_voltage_transformer_params)
    if @medium_voltage_transformer.save
      redirect_to medium_voltage_transformers_path, notice: 'Transformador MT cadastrado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @medium_voltage_transformer = MediumVoltageTransformer.find(params[:id])
  end

  def update
    @medium_voltage_transformer = MediumVoltageTransformer.find(params[:id])
    if @medium_voltage_transformer.update(medium_voltage_transformer_params)
      redirect_to medium_voltage_transformers_path, notice: 'Transformador MT atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @medium_voltage_transformer = MediumVoltageTransformer.find(params[:id])
    serial_number = @medium_voltage_transformer.serial_number
    
    if @medium_voltage_transformer.destroy
      redirect_to medium_voltage_transformers_path, notice: "Transformador MT #{serial_number} removido com sucesso!"
    else
      redirect_to medium_voltage_transformers_path, alert: "Erro ao remover transformador: #{@medium_voltage_transformer.errors.full_messages.join(', ')}"
    end
  end

  private

  def medium_voltage_transformer_params
    params.require(:medium_voltage_transformer).permit(:serial_number, :location_id, :status_id, :notes, :bt_option_id, :power_option_id, :cooling_option_id, :flag_option_id, :installation_option_id)
  end

  def apply_filters_and_sorting
    transformers = MediumVoltageTransformer.includes(:bt_option, :power_option, :location, :status, :cooling_option, :flag_option, :installation_option)

    # Aplicar filtros especiais
    transformers = transformers.without_location if params[:no_location] == 'true'
    transformers = transformers.without_status if params[:no_status] == 'true'
    transformers = transformers.without_power_option if params[:no_power] == 'true'
    transformers = transformers.with_notes if params[:with_notes] == 'true'
    transformers = transformers.without_notes if params[:no_notes] == 'true'

    # Aplicar ordenação
    sort_field = params[:sort_field] || 'serial_number'
    sort_direction = params[:sort_direction] || 'asc'

    case sort_field
    when 'serial_number'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_serial_number_desc : transformers.ordered_by_serial_number
    when 'bt_option'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_bt_option_desc : transformers.ordered_by_bt_option
    when 'power_option'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_power_option_desc : transformers.ordered_by_power_option
    when 'location'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_location_desc : transformers.ordered_by_location
    when 'status'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_status_desc : transformers.ordered_by_status
    when 'cooling_option'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_cooling_option_desc : transformers.ordered_by_cooling_option
    when 'flag_option'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_flag_option_desc : transformers.ordered_by_flag_option
    when 'installation_option'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_installation_option_desc : transformers.ordered_by_installation_option
    when 'created_at'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_created_at_desc : transformers.ordered_by_created_at
    when 'updated_at'
      transformers = sort_direction == 'desc' ? transformers.ordered_by_updated_at_desc : transformers.ordered_by_updated_at
    else
      transformers = transformers.ordered_by_serial_number
    end

    transformers
  end
end
