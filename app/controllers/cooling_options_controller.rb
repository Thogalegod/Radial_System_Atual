class CoolingOptionsController < ApplicationController
  def index
    @cooling_options = CoolingOption.order(:value)
    respond_to do |format|
      format.html
      format.json { render json: @cooling_options }
    end
  end

  def new
    @cooling_option = CoolingOption.new
  end

  def create
    @cooling_option = CoolingOption.new(cooling_option_params)
    if @cooling_option.save
      respond_to do |format|
        format.html { redirect_to params[:redirect_to] || cooling_options_path, notice: 'Refrigeração criada com sucesso!' }
        format.json { render json: { id: @cooling_option.id, value: @cooling_option.value, color: @cooling_option.color } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @cooling_option.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @cooling_option = CoolingOption.find(params[:id])
  end

  def update
    @cooling_option = CoolingOption.find(params[:id])
    if @cooling_option.update(cooling_option_params)
      redirect_to params[:redirect_to] || cooling_options_path, notice: 'Refrigeração atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cooling_option = CoolingOption.find(params[:id])
    if @cooling_option.destroy
      redirect_to params[:redirect_to] || cooling_options_path, notice: 'Refrigeração removida com sucesso!'
    else
      redirect_to params[:redirect_to] || cooling_options_path, alert: @cooling_option.errors.full_messages.join(', ')
    end
  end

  private

  def cooling_option_params
    params.require(:cooling_option).permit(:value)
  end
end
