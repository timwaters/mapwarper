class  OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
     # sign_in @user, :event => :authentication
     # redirect_to session[:user_return_to] root_path
    else
      session["devise.twitter_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
  
   def osm
    @user = User.find_for_osm_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Osm"
      sign_in_and_redirect @user, :event => :authentication
     # sign_in @user, :event => :authentication
     # redirect_to session[:user_return_to] root_path
    else
      session["devise.osm_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
  
  def mediawiki
    @user = User.find_for_mediawiki_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Mediawiki"
      sign_in_and_redirect @user, :event => :authentication
     # sign_in @user, :event => :authentication
     # redirect_to session[:user_return_to] root_path
    else
      session["devise.mediwiki_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
  
  def github
    @user = User.find_for_github_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Github"
      sign_in_and_redirect @user, :event => :authentication
     # sign_in @user, :event => :authentication
     # redirect_to session[:user_return_to] root_path
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end


end
