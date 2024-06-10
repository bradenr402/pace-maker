class ApplicationController < ActionController::Base
  before_actions :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username email])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username email])
  end
end
