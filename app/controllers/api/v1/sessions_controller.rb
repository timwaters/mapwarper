class Api::V1::SessionsController < Devise::SessionsController
  include ActionController::Serialization
  acts_as_token_authentication_handler_for User, :fallback => :none, :except => [:create, :new]
  skip_before_action :verify_authenticity_token
  skip_before_filter :verify_signed_out_user, :only => [:destroy]

  # validates authentication tokens
  # just logs in and if successfully logged in, returns the authentication_token
  def validate_token
    if current_user
      render :json => current_user, 
        :meta => { :authentication_token => current_user.authentication_token }
    else
      render :json => {}.to_json, :status => :unprocessable_entity
    end
  end
  
  # POST /api/v1/auth/sign_in.json
  # Resets the authentication token on log in, so for example if user has two devices, and one logs in, the previous token is invalidated.
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
 
    current_user.update authentication_token: nil
 
    render :json => current_user, 
      :meta => { :authentication_token => current_user.authentication_token }
  end

  # DELETE /api/v1/auth/sign_out.json
  # invalidates the previous token
  def destroy

    if current_user
      current_user.update authentication_token: nil
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      render :json => {}.to_json, :status => :ok
    else
      render :json => {}.to_json, :status => :unprocessable_entity
    end

  end
  
  def new
    return render :json => {:error => "Invalid email or password."}, :status => 401
  end

  
end