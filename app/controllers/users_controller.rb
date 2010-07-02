class UsersController < ApplicationController
   layout 'application'
   before_filter :not_logged_in_required, :only => [:new, :create]
   
   before_filter :login_required, :only => [:show, :edit, :update]
   before_filter :check_super_user_role, :only => [:index, :destroy, :enable, :disable, :force_activate, :disable_and_reset, :force_resend_activaton]
   helper :sort
  include SortHelper
   def index
      @html_title = "Users"
      sort_init 'email'
      sort_update
      @users = User.paginate(:page=> params[:page],
                            :per_page => 30,
                            :order => sort_clause
                            )
   end

  
   def show
      @user = User.find(params[:id]) || current_user
      @html_title = "Showing User "+ @user.login.capitalize
      @mymaps = @user.maps.paginate(:page => params[:page],:per_page => 8, :order => "updated_at DESC")
      @current_user_maps = current_user.maps
   end

   # render new.rhtml
   def new
      @html_title = "Sign Up"
      @user = User.new
   end

   def create
      cookies.delete :auth_token
      @user = User.new(params[:user])
      @user.save!
      # Uncomment to have the user automatically
      # logged in after creating an account - Not Recommended
      # self.current_user = @user
      flash[:notice] = "Thanks for signing up! Please check your email to activate your account before logging in. If you dont recieve an email, then %s"
      flash[:notice_item] = ["click here to resend the email",
        resend_activation_path] 
      redirect_to login_path
   rescue ActiveRecord::RecordInvalid
      flash[:error] = "There was a problem creating your account."
      render :action => 'new'
   end

   def edit
      @html_title = "Edit User Setttings"
      @user = current_user
   end

   def update
      @user = User.find(current_user)
      if @user.update_attributes(params[:user])
         flash[:notice] = "User updated"
         redirect_to :action => 'show', :id => current_user
      else
         render :action => 'edit'
      end
   end

   def destroy
      @user = User.find(params[:id])
      unless @user.has_role?("administrator") ||  @user.has_role?("super user")
        if @user.destroy
          flash[:notice] = "User successfully deleted"
        else
          flash[:error] = "User could not be deleted"
        end
      else
        flash[:error] = "Admins cannot be destroyed"
      end
      redirect_to :action => 'index'
   end

   def disable_and_reset
     @user = User.find(params[:id])
     unless @user.has_role?("administrator") ||  @user.has_role?("super user")
       #disable
      if @user.update_attribute(:enabled, false)
         @user.forgot_password
         @user.save  #user_observer sends password now
         flash[:notice] = "User disabled, and an email sent with password reset link"
       else
        flash[:error] = "Sorry, there was a problem disbaling this user"
       end
     else
       flash[:error] = "Admins cannot be disabled and reset, sorry"
     end
     redirect_to :action => 'show'
   end

   def disable
      @user = User.find(params[:id])
      if @user.update_attribute(:enabled, false)
         flash[:notice] = "User disabled"
      else
         flash[:error] = "There was a problem disabling this user."
      end
      redirect_to :action => 'index'
   end

   def enable
      @user = User.find(params[:id])
      if @user.update_attribute(:enabled, true)
         flash[:notice] = "User enabled"
      else
         flash[:error] = "There was a problem enabling this user."
      end
      redirect_to :action => 'index'
   end

   def activate  
      @user = User.find_by_activation_code(params[:id])
      if @user and @user.activate
         self.current_user = @user
         redirect_back_or_default(:controller => '/user_account', :action => 'index')
         flash[:notice] = "Your account has been activated."
     end
      redirect_to :action => 'index'
   end


#   def activate
#     @user = User.find_by_activation_code(params[:id]) unless params[:id].blank?
#     if @user and @user.activate
#       self.current_user = @user
#      # redirect_back_or_default(:action => 'show')
#       flash[:notice] = "Signup complete! Please sign in to continue."
#       redirect_to login_path
#     elsif params[:id].blank?
#       flash[:error] = "The activation code was missing. Please follow the URL from your email."
#       redirect_back_or_default('/')
#     else
#       flash[:error] = "We couldn't find a  user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
#       redirect_back_or_default('/')
#     end
  #  end

  #called from admin console thingy
   def force_activate
     @user = User.find(params[:id])
     if !@user.active?
       @user.force_activate!
       if @user.active? 
         flash[:notice] = "User activated"
       else
         flash[:error] = "There was a problem activating this user."
       end
     else
       flash[:notice] = "User already active"
     end
     redirect_to :action => 'index'
   end
   
   #only admin can do this
   def force_resend_activation
     @user = User.find(params[:id])
      if @user && !@user.active?
        flash[:notice] = "Activation email sent to user."
        UserMailer.deliver_signup_notification(@user)
      else
        flash[:notice] = "Activation email was not sent, maybe because it has already been activated!"
      end
      redirect_to :action => 'show'
   end

   def resend_activation
    return unless request.post?

    @user = User.find_by_email(params[:email])
    if @user && !@user.active?
      flash[:notice] = "Activation email has been resent, check your email."
      UserMailer.deliver_signup_notification(@user)
      redirect_to login_path and return
    else
      flash[:notice] = "Activation email was not sent, either because the email was not the same as you gave when you signed up, or you have already been activated!"
      
    end
   end

end
