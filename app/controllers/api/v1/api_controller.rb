class Api::V1::ApiController < ActionController::API
  include ActionController::Serialization
    
  def check_administrator_role
    check_role("administrator")
  end

  def check_role(role)
    unless user_signed_in? && @current_user.has_role?(role)
      permission_denied
    end
  end

  def permission_denied
    self.status  = :unauthorized
    self.content_type  = "application/json"
    self.response_body = { errors: ["Unauthorized Request"] }.to_json
  end

end
