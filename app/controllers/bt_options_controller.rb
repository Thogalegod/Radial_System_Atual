class BtOptionsController < ApplicationController
  def index
    @bt_options = BtOption.order(:value)
  end

  def new
    @bt_option = BtOption.new
  end

  def create
    @bt_option = BtOption.new(bt_option_params)
    if @bt_option.save
      redirect_to params[:redirect_to] || bt_options_path, notice: 'Opção de BT criada com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @bt_option = BtOption.find(params[:id])
  end

  def update
    @bt_option = BtOption.find(params[:id])
    if @bt_option.update(bt_option_params)
      redirect_to params[:redirect_to] || bt_options_path, notice: 'Opção de BT atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bt_option = BtOption.find(params[:id])
    if @bt_option.destroy
      redirect_to params[:redirect_to] || bt_options_path, notice: 'Opção de BT removida com sucesso!'
    else
      redirect_to params[:redirect_to] || bt_options_path, alert: @bt_option.errors.full_messages.join(', ')
    end
  end

  private

  def bt_option_params
    params.require(:bt_option).permit(:value)
  end
end
