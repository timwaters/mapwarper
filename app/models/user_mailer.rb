class UserMailer < ActionMailer::Base
  OURSITE = SITE_URL
  OURSITE = OURSITE + ActionController::Base.relative_url_root unless ActionController::Base.relative_url_root.blank?
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://#{OURSITE}/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{OURSITE}/"
  end

  def disabled_change_password(user)
    setup_email(user)
    @subject += "You account is disabled until you change your password"
    @body[:url] = "http://#{OURSITE}/reset_password/#{user.password_reset_code}"
  end

  def forgot_password(user)
    setup_email(user)
    @subject += "You have requested to change your password"
    @body[:url] = "http://#{OURSITE}/reset_password/#{user.password_reset_code}"
  end
  
  def reset_password(user)
    setup_email(user)
    @subject += "Your password has been reset"
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "#{SITE_EMAIL}"
      @subject     = "Map Warper - "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
