class ClientsController < ApplicationController
  before_action :require_login
  before_action :set_client, only: [:show, :edit, :update, :destroy, :contacts]

  def index
    @clients = Client.includes(:contacts).all.order(:name)
  end

  def show
  end

  def new
    @client = Client.new
    @client.contacts.build
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      redirect_to clients_path, notice: 'Cliente cadastrado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @client.contacts.build if @client.contacts.empty?
  end

  def update
    if @client.update(client_params)
      redirect_to clients_path, notice: 'Cliente atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: 'Cliente removido com sucesso!'
  end

  def contacts
    @contacts = @client.contacts.order(:name => :asc)
    render json: { 
      contacts: @contacts.map do |contact|
        {
          id: contact.id,
          name: contact.name,
          email: contact.email,
          phone: contact.phone,
          position: contact.position,
          is_primary: contact.id == @client.contacts.first&.id
        }
      end
    }
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(
      :name, :address, :document_type, :document_number, 
      :zip_code, :state_registration,
      contacts_attributes: [:id, :name, :email, :phone, :position, :_destroy]
    )
  end



  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
