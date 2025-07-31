class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
  end

  def create
    # Validação básica dos parâmetros
    if params[:email].blank? || params[:password].blank?
      flash.now[:alert] = 'Email e senha são obrigatórios'
      render :new, status: :unprocessable_entity
      return
    end

    # Validação de formato de email
    unless valid_email?(params[:email])
      flash.now[:alert] = 'Formato de email inválido'
      render :new, status: :unprocessable_entity
      return
    end

    # Busca do usuário
    user = User.find_by(email: params[:email].downcase.strip)
    
    if user&.authenticate(params[:password])
      log_in(user)
      redirect_to dashboard_path, notice: 'Login realizado com sucesso!'
    else
      # Não revelar se o email existe ou não por segurança
      flash.now[:alert] = 'Email ou senha inválidos'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to login_path, notice: 'Logout realizado com sucesso!'
  end

  private

  def valid_email?(email)
    email =~ URI::MailTo::EMAIL_REGEXP
  end
end
