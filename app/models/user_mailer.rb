class UserMailer < ActionMailer::Base
  default from: APP_CONFIG['mailer_sender']

  def disabled_change_password(user)
    @user = user
    @subject = "Map Warper You account is disabled until you change your password"
    mail(to: @recipients, subject: @subject)
  end


end
