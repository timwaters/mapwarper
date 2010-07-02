class UserAccountsController < ApplicationController
   layout 'application'
   before_filter :login_required, :except => :show
   before_filter :not_logged_in_required, :only => :show

   # Activate action
   def show
      # Uncomment and change paths to have user logged in after activation - not recommended
      #self.current_user = User.find_and_activate!(params[:id])
      User.find_and_activate!(params[:id])
      flash[:notice] = "Your account has been activated! You can now login."
      redirect_to login_path
   rescue User::ArgumentError
      flash[:notice] = 'Activation code not found. Please try creating a new account. Or we can try to %s'
      flash[:notice_item] = ["resend the email here", resend_activation_path]
      redirect_to new_user_path
   rescue User::ActivationCodeNotFound
      flash[:notice] = 'Activation code not found. Please try creating a new account. Or we can try to %s'
flash[:notice_item] = [" resend the email here", resend_activation_path]

      redirect_to new_user_path
   rescue User::AlreadyActivated
      flash[:notice] = 'Your account has already been activated. You can log in below.'
      redirect_to login_path
   end

   def edit
     @html_title = "Change Password"
   end

   # Change password action
   def update
      return unless request.post?
      if User.authenticate(current_user.email, params[:old_password])
         if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
            current_user.password_confirmation = params[:password_confirmation]
            current_user.password = params[:password]
            if current_user.save
               flash[:notice] = "Password successfully updated."
               redirect_to root_path #profile_url(current_user.login)
            else
               flash[:error] = "An error occured, your password was not changed."
               render :action => 'edit'
            end
         else
            flash[:error] = "New password does not match the password confirmation."
            @old_password = params[:old_password]
            render :action => 'edit'
         end
      else
         flash[:error] = "Your old password is incorrect."
         render :action => 'edit'
      end
   end

end
