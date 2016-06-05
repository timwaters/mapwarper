class  OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_render_or_redirect
    else
      session["devise.twitter_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
  
   def osm
    @user = User.find_for_osm_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Osm"
      sign_in_render_or_redirect
    else
      session["devise.osm_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

  def mediawiki
    @user = User.find_for_mediawiki_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Mediawiki"
      sign_in_render_or_redirect
    else
      session["devise.mediawiki_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
  
  def github
    @user = User.find_for_github_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Github"
      sign_in_render_or_redirect
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

  protected
  
  def sign_in_render_or_redirect
    # sign_in_and_redirect @user, :event => :authentication
    sign_in @user, :event => :authentication
    
    if ['inAppBrowser', 'newWindow'].include?(omniauth_window_type)
      render :layout => nil, :template => "devise/omniauth_external_window"
    else
      redirect_to after_sign_in_path_for(@user)
    end
    
  end
  
  def user_json(user)
    @user.as_json(:only => [:id, :login, :email, :provider, :uid, :authentication_token] )
  end
  
  ####
  # From  https://github.com/lynndylanhurley/devise_token_auth/blob/master/app/controllers/devise_token_auth/omniauth_callbacks_controller.rb (DWTF license)
  ####

  
  def omniauth_window_type
    omniauth_params.nil? ? params['omniauth_window_type'] : omniauth_params['omniauth_window_type']
  end
  
  def omniauth_params
    if !defined?(@_omniauth_params)
      if request.env['omniauth.params'] && request.env['omniauth.params'].any?
        @_omniauth_params = request.env['omniauth.params']
      elsif session['dta.omniauth.params'] && session['dta.omniauth.params'].any?
        @_omniauth_params ||= session.delete('dta.omniauth.params')
        @_omniauth_params
      elsif params['omniauth_window_type']
        @_omniauth_params = params.slice('omniauth_window_type', 'auth_origin_url', 'resource_class', 'origin')
      else
        @_omniauth_params = {}
      end
    end
    @_omniauth_params
    
  end
end
