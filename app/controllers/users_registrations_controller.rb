class UsersRegistrationsController < Devise::RegistrationsController

  def create
    super
    if @user.persisted?
      UserMailer.new_registration(@user).deliver
    end
  end

end
