class UsersController < ApplicationController
  before_action :require_login, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: 'Cadastro realizado com sucesso!'
    else
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

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar o dashboard.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
