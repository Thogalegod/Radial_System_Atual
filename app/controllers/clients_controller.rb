class ClientsController < ApplicationController
  before_action :require_login
  before_action :set_client, only: [:show, :edit, :update, :destroy]

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
      # Garantir que apenas um contato seja principal
      ensure_single_primary_contact(@client)
      redirect_to clients_path, notice: 'Cliente atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: 'Cliente removido com sucesso!'
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    # Converter is_primary de string para boolean
    params_copy = params.require(:client).permit(
      :name, :address, :document_type, :document_number, 
      :zip_code, :state_registration,
      contacts_attributes: [:id, :name, :email, :phone, :position, :is_primary, :_destroy]
    )
    
    # Converter is_primary para boolean e garantir que apenas um seja true
    if params_copy[:contacts_attributes].present?
      primary_found = false
      params_copy[:contacts_attributes].each do |key, contact_attrs|
        if contact_attrs[:is_primary] == "1" && !primary_found
          contact_attrs[:is_primary] = true
          primary_found = true
        else
          contact_attrs[:is_primary] = false
        end
      end
      
      # Se nenhum contato foi marcado como principal, marca o primeiro
      if !primary_found && params_copy[:contacts_attributes].keys.any?
        first_key = params_copy[:contacts_attributes].keys.first
        params_copy[:contacts_attributes][first_key][:is_primary] = true
      end
    end
    
    params_copy
  end

  def ensure_single_primary_contact(client)
    primary_contacts = client.contacts.where(is_primary: true)
    
    if primary_contacts.count > 1
      # Se há mais de um contato principal, mantém apenas o primeiro
      first_primary = primary_contacts.first
      primary_contacts.where.not(id: first_primary.id).update_all(is_primary: false)
    elsif primary_contacts.count == 0 && client.contacts.any?
      # Se não há contato principal mas há contatos, marca o primeiro como principal
      client.contacts.first.update(is_primary: true)
    end
  end

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
