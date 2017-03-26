class Api::V1::ApiController < ActionController::API
  include ActionController::Serialization
  acts_as_token_authentication_handler_for User, :fallback => :none
  before_filter :check_protocol
  
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
  
  def validate_jsonapi_type
    type = controller_name.classify.downcase.pluralize
    unless params[:data] && params[:data][:type]
      render :json => { :errors => [{:title => "Missing param", :detail =>"params data or type is missing"}]},:status => :unprocessable_entity
      return
    end
    if params[:data][:type] != type
      render :json => { :errors => [{:title => "Invalid param", :detail => "params type should be '#{type}'"}]}, :status => :unprocessable_entity
      return
    end
  end
  
  def index
    m = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :fenced_code_blocks => true,
      :autolink => true,
      :tables => true,
      :hard_wrap =>true )
    content = m.render(File.open(Rails.root + "README_API.md", 'r').read)
    render :html => content.html_safe, :layout => 'layouts/markdown'
  end
  
  protected
  #
  # Needed to make sure the right protocol is set in the url helpers in the serializers
  #
  def check_protocol
    if request.ssl?
      Rails.application.routes.default_url_options[:protocol] = 'https'
    else
      Rails.application.routes.default_url_options[:protocol] = 'http'
    end
  end

end
