class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user)
  end

  def after_save(user)
    
    UserMailer.deliver_activation(user) if user.pending?
    UserMailer.deliver_reset_password(user) if user.recently_reset_password?
    if user.recently_forgot_password?
      if !user.enabled?
        UserMailer.deliver_disabled_change_password(user)
      else
        UserMailer.deliver_forgot_password(user)
      end
    end
  end
end
