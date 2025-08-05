class ClientsController < ApplicationController
  before_action :require_login
  before_action -> { require_resource_permission(:clients, :read) }, only: [:index, :show]
  before_action -> { require_resource_permission(:clients, :create) }, only: [:new, :create]
  before_action -> { require_resource_permission(:clients, :update) }, only: [:edit, :update]
  before_action -> { require_resource_permission(:clients, :destroy) }, only: [:destroy]
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
end
