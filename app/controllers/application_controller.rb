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
    unless current_user&.admin?
      redirect_to dashboard_path, alert: 'Acesso negado. Apenas administradores podem acessar esta área.'
    end
  end

  def require_manager_or_admin
    unless current_user&.admin? || current_user&.manager?
      redirect_to dashboard_path, alert: 'Acesso negado. Apenas gerentes e administradores podem acessar esta área.'
    end
  end

  def require_permission(permission)
    unless current_user&.can?(permission)
      redirect_to dashboard_path, alert: 'Acesso negado. Você não tem permissão para acessar esta área.'
    end
  end

  def require_resource_permission(resource, action = nil)
    unless current_user&.can_access?(resource, action)
      redirect_to dashboard_path, alert: "Acesso negado. Você não tem permissão para #{action || 'acessar'} #{resource}."
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

  # Helper methods para views
  helper_method :current_user, :logged_in?, :user_can?

  def user_can?(permission)
    current_user&.can?(permission) || false
  end

  def user_can_access?(resource, action = nil)
    current_user&.can_access?(resource, action) || false
  end
end
