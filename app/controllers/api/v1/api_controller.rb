class Api::V1::ApiController < ActionController::API
  include ActionController::Serialization
  acts_as_token_authentication_handler_for User, :fallback => :none
  
  def check_administrator_role
    check_role("administrator")
  end
  
  def check_editor_role
    check_role("editor")
  end

  def check_role(role)
    unless user_signed_in? && @current_user.has_role?(role)
      permission_denied
    end
  end

  def permission_denied
    self.status  = :unauthorized
    self.content_type  = "application/json"
    self.response_body = { :errors => [{:title => "Unauthorized", :detail => "Unauthorized Request"}] }.to_json
  end
  
  def not_found(exception)
    render :json => { :errors => [{:title => "Not found", :detail => exception.message}] }, :status => :not_found
  end
  
  def missing_param_error(exception)
    render :json => { :errors => [{:title => "Missing param", :detail => exception.message}]},:status => :unprocessable_entity
  end

end
