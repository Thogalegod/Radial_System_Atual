class UsersController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]
  before_action :require_login, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    # Validação adicional de email
    if user_params[:email].present?
      @user.email = user_params[:email].downcase.strip
    end
    
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
    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end
end
