class ApplicationController < ActionController::Base
  check_authorization unless: :devise_controller?

  protected

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end
end
