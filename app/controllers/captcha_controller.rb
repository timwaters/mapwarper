class CaptchaController < ApplicationController
  include Hcaptcha::Adapters::ControllerMethods
  include Hcaptcha::Adapters::ViewMethods

  skip_before_action :require_hcaptcha

  def show
  end

  def verify
    if verify_hcaptcha
      session[:hcaptcha_verified] = true
      redirect_to(params[:return_to].presence || root_path)
    else
      flash.now[:alert] = "Captcha verification failed."
      render :show
    end
  end

end