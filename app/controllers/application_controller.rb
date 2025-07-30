class ApplicationController < ActionController::Base
  before_action :set_current_user

  private

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_user
    @current_user
  end

  def require_login
    unless current_user
      redirect_to login_path, alert: 'Faça login para acessar esta área.'
    end
  end

  def require_admin
    unless current_user&.role == 'admin'
      redirect_to dashboard_path, alert: 'Acesso negado. Apenas administradores podem acessar esta área.'
    end
  end

  def logged_in?
    !!current_user
  end

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def redirect_if_logged_in
    redirect_to dashboard_path if logged_in?
  end
end
