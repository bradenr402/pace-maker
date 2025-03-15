class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_breadcrumbs

  add_flash_types :success, :error

  def add_breadcrumb(name, url = '') = @breadcrumbs << { name:, url: }

  def prepend_breadcrumb(name, url = '') = @breadcrumbs.prepend({ name:, url: })

  private

  def set_breadcrumbs = @breadcrumbs = []

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: %i[username email]
    devise_parameter_sanitizer.permit :sign_in, keys: %i[login password]
    devise_parameter_sanitizer.permit :account_update,
                                      keys: %i[
                                        display_name
                                        username
                                        email
                                        phone_number
                                        phone_country_code
                                      ]
  end
end
