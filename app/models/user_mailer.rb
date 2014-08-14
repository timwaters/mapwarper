class UserMailer < ActionMailer::Base
  default from: APP_CONFIG['email']

  def disabled_change_password(user)
    @user = user
    @subject = "#{APP_CONFIG['site_name']} You account is disabled until you change your password"
    mail(to: @user.email, subject: @subject)
  end

  def new_registration(user)
    @user = user
    @subject = "Welcome to #{APP_CONFIG['site_name']} #{@user.login}"
    mail(to: @user.email, subject: @subject)
  end

end
