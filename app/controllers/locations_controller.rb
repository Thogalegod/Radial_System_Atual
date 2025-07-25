class LocationsController < ApplicationController
  def index
    @locations = Location.order(:value)
    respond_to do |format|
      format.html
      format.json { render json: @locations }
    end
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      respond_to do |format|
        format.html { redirect_to params[:redirect_to] || locations_path, notice: 'Localização criada com sucesso!' }
        format.json { render json: { id: @location.id, value: @location.value, color: @location.color } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @location.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    if @location.update(location_params)
      redirect_to params[:redirect_to] || locations_path, notice: 'Localização atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location = Location.find(params[:id])
    if @location.destroy
      redirect_to params[:redirect_to] || locations_path, notice: 'Localização removida com sucesso!'
    else
      redirect_to params[:redirect_to] || locations_path, alert: @location.errors.full_messages.join(', ')
    end
  end

  private

  def location_params
    params.require(:location).permit(:value)
  end
end
