class InstallationOptionsController < ApplicationController
  def index
    @installation_options = InstallationOption.order(:value)
    respond_to do |format|
      format.html
      format.json { render json: @installation_options }
    end
  end

  def new
    @installation_option = InstallationOption.new
  end

  def create
    @installation_option = InstallationOption.new(installation_option_params)
    if @installation_option.save
      respond_to do |format|
        format.html { redirect_to params[:redirect_to] || installation_options_path, notice: 'Instalação criada com sucesso!' }
        format.json { render json: { id: @installation_option.id, value: @installation_option.value, color: @installation_option.color } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @installation_option.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @installation_option = InstallationOption.find(params[:id])
  end

  def update
    @installation_option = InstallationOption.find(params[:id])
    if @installation_option.update(installation_option_params)
      redirect_to params[:redirect_to] || installation_options_path, notice: 'Instalação atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @installation_option = InstallationOption.find(params[:id])
    if @installation_option.destroy
      redirect_to params[:redirect_to] || installation_options_path, notice: 'Instalação removida com sucesso!'
    else
      redirect_to params[:redirect_to] || installation_options_path, alert: @installation_option.errors.full_messages.join(', ')
    end
  end

  private

  def installation_option_params
    params.require(:installation_option).permit(:value)
  end
end
