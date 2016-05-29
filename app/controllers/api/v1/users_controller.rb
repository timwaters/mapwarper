class Api::V1::UsersController < Api::V1::ApiController
  before_filter :authenticate_user!
  before_filter :check_administrator_role, :except => [:show]
  
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  def show
    @user = User.find(params[:id])
    render :json => @user, :include => ['roles']
  end
  
  def index
    sort_order = "desc"
    sort_order = "asc" if index_params[:sort_order] == "asc"
    sort_key = %w(login email created_at enabled provider).detect{|f| f == (index_params[:sort_key])}
    sort_key = sort_key || "updated_at" if sort_order == "desc"

    order_options = "#{sort_key} #{sort_order}"

    @query = params[:query]
    @field = %w(login email provider).detect{|f| f == (params[:field])}
    if @query && @query.strip.length > 0 && @field
      conditions = ["#{@field}  ~* ?", '(:punct:|^|)'+@query+'([^A-z]|$)']
    else
      conditions = nil
    end
    @users = User.where(conditions).order(order_options).paginate(:page=> params[:page], :per_page => 30)
    render :json => @users, :include => ['roles']
  end
  
  private
  def index_params
    params.permit(:page, :per_page, :query, :field, :sort_key, :sort_order, :field,  :format)
  end
  
  
end