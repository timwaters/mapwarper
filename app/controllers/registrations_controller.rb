class RegistrationsController < Devise::RegistrationsController
  include Hcaptcha::Adapters::ControllerMethods
  include Hcaptcha::Adapters::ViewMethods
  prepend_before_action :check_hcaptcha, only: [:create] if ENV["HCAPTCHA_SITE_KEY"]  

  private
    def check_hcaptcha
      self.resource = resource_class.new sign_up_params
      unless verify_hcaptcha(model: resource)
        respond_with_navigational(resource){ redirect_to new_user_registration_path }
      end

    end
end