class UsersController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]
  before_action :require_login, only: [:show, :index, :edit, :update, :destroy]
  before_action :require_admin, only: [:index, :edit, :update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all.order(:name)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    # Validação adicional de email
    if user_params[:email].present?
      @user.email = user_params[:email].downcase.strip
    end
    
    # Definir role padrão se não for admin
    @user.role = 'viewer' if @user.role.blank?
    
    if @user.save
      log_in(@user)
      redirect_to dashboard_path, notice: 'Cadastro realizado com sucesso!'
    else
      # Melhorar mensagens de erro
      if @user.errors[:email].any?
        flash.now[:alert] = "Email: #{@user.errors[:email].join(', ')}"
      elsif @user.errors[:password].any?
        flash.now[:alert] = "Senha: #{@user.errors[:password].join(', ')}"
      elsif @user.errors[:name].any?
        flash.now[:alert] = "Nome: #{@user.errors[:name].join(', ')}"
      else
        flash.now[:alert] = 'Erro ao criar conta. Verifique os dados informados.'
      end
      
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Usuários só podem ver seu próprio perfil, exceto admins
    unless current_user.admin? || current_user.id == @user.id
      redirect_to dashboard_path, alert: 'Você só pode visualizar seu próprio perfil.'
    end
  end

  def edit
    # Apenas admins podem editar outros usuários
    unless current_user.admin? || current_user.id == @user.id
      redirect_to dashboard_path, alert: 'Você só pode editar seu próprio perfil.'
    end
  end

  def update
    # Apenas admins podem editar outros usuários
    unless current_user.admin? || current_user.id == @user.id
      redirect_to dashboard_path, alert: 'Você só pode editar seu próprio perfil.'
    end

    if @user.update(user_params)
      redirect_to @user, notice: 'Perfil atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Apenas admins podem deletar usuários
    unless current_user.admin?
      redirect_to dashboard_path, alert: 'Apenas administradores podem deletar usuários.'
    end

    if @user.destroy
      redirect_to users_path, notice: 'Usuário removido com sucesso!'
    else
      redirect_to @user, alert: 'Erro ao remover usuário.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    if current_user&.admin?
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
    else
      # Usuários não-admin só podem editar nome e email
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end
end
