class ApplicationController < ActionController::Base
  check_authorization unless: :devise_controller?
  skip_authorization_check only: :not_found

  def not_found
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end

  protected

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end
end
