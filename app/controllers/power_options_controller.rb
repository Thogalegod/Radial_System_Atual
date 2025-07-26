class PowerOptionsController < ApplicationController
  def index
    @power_options = PowerOption.order(:value)
    respond_to do |format|
      format.html
      format.json { render json: @power_options }
    end
  end

  def new
    @power_option = PowerOption.new
  end

  def create
    @power_option = PowerOption.new(power_option_params)
    if @power_option.save
      respond_to do |format|
        format.html { redirect_to params[:redirect_to] || power_options_path, notice: 'Opção de potência criada com sucesso!' }
        format.json { render json: { id: @power_option.id, value: @power_option.value, color: @power_option.color } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @power_option.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @power_option = PowerOption.find(params[:id])
  end

  def update
    @power_option = PowerOption.find(params[:id])
    if @power_option.update(power_option_params)
      redirect_to params[:redirect_to] || power_options_path, notice: 'Opção de potência atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @power_option = PowerOption.find(params[:id])
    if @power_option.destroy
      redirect_to params[:redirect_to] || power_options_path, notice: 'Opção de potência removida com sucesso!'
    else
      redirect_to params[:redirect_to] || power_options_path, alert: @power_option.errors.full_messages.join(', ')
    end
  end

  private

  def power_option_params
    params.require(:power_option).permit(:value)
  end
end
