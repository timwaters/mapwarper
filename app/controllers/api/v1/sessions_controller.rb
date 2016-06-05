class Api::V1::SessionsController < Api::V1::ApiController
  before_filter :authenticate_user!
  
  def validate_token
    render :json => current_user
  end
  
end