class UserMailer < ActionMailer::Base
  default from: APP_CONFIG['email']

  def disabled_change_password(user)
    @user = user
    @subject = I18n.t('user_mailer.disabled_change_password.subject', :site_name => APP_CONFIG['site_name'])
    mail(to: @user.email, subject: @subject)
  end
  
  def new_registration(user)
    @user = user
    @subject = I18n.t('user_mailer.new_registration.subject', :site_name => APP_CONFIG['site_name'], :user_name =>@user.login )
    mail(to: @user.email, subject: @subject)
  end

  def old_user_notify(user)
    @user = user
    @subject = I18n.t('user_mailer.old_user_notify.subject', :site_name => APP_CONFIG['full_site_name'], :user_name =>@user.login, :map_count => @user.own_maps_count)
    
    mail(to: @user.email, subject: @subject, reply_to: APP_CONFIG['reply_to'])
  end

end
