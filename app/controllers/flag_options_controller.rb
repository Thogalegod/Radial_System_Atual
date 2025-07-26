class FlagOptionsController < ApplicationController
  def index
    @flag_options = FlagOption.order(:value)
    respond_to do |format|
      format.html
      format.json { render json: @flag_options }
    end
  end

  def new
    @flag_option = FlagOption.new
  end

  def create
    @flag_option = FlagOption.new(flag_option_params)
    if @flag_option.save
      respond_to do |format|
        format.html { redirect_to params[:redirect_to] || flag_options_path, notice: 'Bandeira criada com sucesso!' }
        format.json { render json: { id: @flag_option.id, value: @flag_option.value, color: @flag_option.color } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @flag_option.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @flag_option = FlagOption.find(params[:id])
  end

  def update
    @flag_option = FlagOption.find(params[:id])
    if @flag_option.update(flag_option_params)
      redirect_to params[:redirect_to] || flag_options_path, notice: 'Bandeira atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @flag_option = FlagOption.find(params[:id])
    if @flag_option.destroy
      redirect_to params[:redirect_to] || flag_options_path, notice: 'Bandeira removida com sucesso!'
    else
      redirect_to params[:redirect_to] || flag_options_path, alert: @flag_option.errors.full_messages.join(', ')
    end
  end

  private

  def flag_option_params
    params.require(:flag_option).permit(:value)
  end
end
