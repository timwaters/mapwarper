class UserMailer < ActionMailer::Base
  default from: APP_CONFIG['email']

  def disabled_change_password(user)
    @user = user
    @subject = t('user_mailer.disabled_change_password.subject', :site_name => APP_CONFIG['site_name'])
    mail(to: @user.email, subject: @subject)
  end
  
  def new_registration(user)
    @user = user
    @subject = t('user_mailer.new_registration.subject', :site_name => APP_CONFIG['site_name'], :user_name =>@user.login )
    mail(to: @user.email, subject: @subject)
  end

end
