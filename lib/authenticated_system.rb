module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
     # !!current_user
      current_user != :false
    end

    # Accesses the current user from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false )
    #  logger.info @current_user.inspect
    #  @current_user
    end

    # Store the given user id in the session.
    def current_user=(new_user)
      session[:user_id] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil :  new_user.id
      @current_user = new_user || :false
    end

    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?
      logged_in?
    end
    # This is ususally what you want; resetting the session willy-nilly wreaks
    # havoc with forgery protection, and is only strictly necessary on login.
    # However, **all session state variables should be unset here**.
    def logout_keeping_session!
      # Kill server-side auth cookie
      @current_user.forget_me if @current_user.is_a? User
      @current_user = false # not logged in, and don't do it for me
      kill_remember_cookie! # Kill client-side auth cookie
      session[:user_id] = nil # keeps the session but kill our variable
      # explicitly kill any other session variables you set
    end
   # The session should only be reset at the tail end of a form POST --
    # otherwise the request forgery protection fails. It's only really necessary
    # when you cross quarantine (logged-out to logged-in).
    def logout_killing_session!
      logout_keeping_session!
      reset_session
    end

    def kill_remember_cookie!
      cookies.delete :auth_token
    end
    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    def not_logged_in_required
      !logged_in? || permission_denied
    end

  def admin_authorized?
    logged_in? && @current_user.has_role?('administrator')
  end
      
  def editor_authorized?
    logged_in? && @current_user.has_role?('editor')
  end

  def check_role(role)
    unless logged_in? && @current_user.has_role?(role)
      if logged_in?
        permission_denied
      else
        store_referer
        access_denied
      end
   end
  end

  def check_super_user_role
   check_role('super user')
  end
    
  def check_administrator_role
    check_role("administrator")
  end

   def check_developer_role
    check_role("developer")
  end
    
    

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      logger.debug("access_denied")
      respond_to do |format|
        format.html do
          if request.xhr?
          store_location
          #send a javascript-based redirect
            render :inline => "<script>document.location.href = '<%=url_for(new_session_path)%>';</script>"
            return
          else
          store_location
          redirect_to new_session_path
        end
          end
        flash.now[:error] = "Access denied, you may need to log in."
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    def permission_denied
      respond_to do |format|
        format.html do
          domain_name = "http://"+ SITE_URL
          dname_len = domain_name.length
          http_referer = session[:refer_to]
          if http_referer.nil?
            store_referer
            http_referer = ( session[:refer_to] || domain_name )
          end

          #flash[:error] = "You don't have permission to complete that action"
          if http_referer[0..(dname_len-1)] != domain_name
            session[:refer_to] = nil
            redirect_to root_path
          else
            redirect_to_referer_or_default(root_path)
          end
        end
        format.xml do
          headers["Status"] = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm= "Web Password")
          render :text => "You don't have permission to complete that action.", :status => '401 Unauthorized'
        end
      end
    end


    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
        session[:return_to] = request.request_uri
    end

    def store_referer
      session[:refer_to] = request.env["HTTP_REFERER"]
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      #logger.info "redirecting back or default"
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def redirect_to_referer_or_default(default)
      #logger.info "redirect to referer or default"
        session[:refer_to] = nil if logged_in? && !session[:refer_to].nil?
        redirect_to(session[:refer_to] || default)
        session[:refer_to] = nil
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :admin_authorized? 
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_user = User.authenticate(username, password)
      end
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end
end
