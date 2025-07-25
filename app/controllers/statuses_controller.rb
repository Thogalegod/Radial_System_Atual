class StatusesController < ApplicationController
  def index
    @statuses = Status.order(:value)
    respond_to do |format|
      format.html
      format.json { render json: @statuses }
    end
  end

  def new
    @status = Status.new
  end

  def create
    @status = Status.new(status_params)
    if @status.save
      respond_to do |format|
        format.html { redirect_to params[:redirect_to] || statuses_path, notice: 'Status criado com sucesso!' }
        format.json { render json: { id: @status.id, value: @status.value, color: @status.color } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @status.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @status = Status.find(params[:id])
  end

  def update
    @status = Status.find(params[:id])
    if @status.update(status_params)
      redirect_to params[:redirect_to] || statuses_path, notice: 'Status atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @status = Status.find(params[:id])
    if @status.destroy
      redirect_to params[:redirect_to] || statuses_path, notice: 'Status removido com sucesso!'
    else
      redirect_to params[:redirect_to] || statuses_path, alert: @status.errors.full_messages.join(', ')
    end
  end

  private

  def status_params
    params.require(:status).permit(:value)
  end
end
