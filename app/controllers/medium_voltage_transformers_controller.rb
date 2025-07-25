class MediumVoltageTransformersController < ApplicationController
  def index
    @medium_voltage_transformers = MediumVoltageTransformer.includes(:bt_option, :location, :status).order(:serial_number)
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
    @medium_voltage_transformer.destroy
    redirect_to medium_voltage_transformers_path, notice: 'Transformador MT removido com sucesso!'
  end

  private

  def medium_voltage_transformer_params
    params.require(:medium_voltage_transformer).permit(:serial_number, :location_id, :status_id, :notes, :bt_option_id)
  end
end
