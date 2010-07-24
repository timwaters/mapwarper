# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
   layout 'application'
   before_filter :login_required, :only => :destroy
  # before_filter :not_logged_in_required, :only => [ :create]
 before_filter :not_logged_in_required, :only => [:new, :create]
   # render new.rhtml
   def new
     @html_title = "Login"
     if  (["Rectify_tab", "Crop_tab", "Align_tab", "Export_tab","Activity_tab", "Comments_tab"].include?(params[:back].to_s) && params[:mapid])
       session[:return_to] = map_path(:id => params[:mapid], :anchor => params[:back])
   end
   end

   def create
      password_authentication(params[:email], params[:password])
   end

   def destroy
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:notice] = "You have been logged out."
      redirect_to login_path
   end

   protected

   def password_authentication(email, password)

      user = User.authenticate(email, password)
        logger.info user
      if user == nil
       
         failed_login("Your email or password is incorrect.")
      elsif user.activated_at.blank?
         failed_login("Your account is not active, please check your email for the activation code. %s", ["Resend activation email?", resend_activation_path])
      elsif user.enabled == false
         failed_login("Your account has been disabled.")
      else
         self.current_user = user
         successful_login
      end
   end

   private

   def failed_login(message, item="")
      flash.now[:error] = message
      flash.now[:error_item] = item
      render :action => 'new'
   end

   def successful_login
      if params[:remember_me] == "1"
         self.current_user.remember_me
         cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash.now[:notice] = "Logged in successfully"
      #logger.info "successful login = " + session[:return_to]
      return_to = session[:return_to]
      if return_to.nil?
         redirect_to user_path(self.current_user)
      else
         redirect_to return_to
      end
   end

end
