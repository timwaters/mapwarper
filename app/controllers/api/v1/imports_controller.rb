class Api::V1::ImportsController < Api::V1::ApiController
  before_filter :authenticate_user!
  before_filter :check_editor_role
  before_filter :find_import, :only => [:show, :update, :destroy, :start, :maps]
  
  before_filter :validate_jsonapi_type,:only => [:create, :update]
   
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_param_error

  def show
    render :json => @import
  end
  
  def create
    @import = Import.new(import_params)
    @import.user = current_user
    @import.uploader_user_id = current_user.id
    if @import.save
      render :json => @import, :status => :created
    else
      render :json => @import, :status => :unprocessable_entity,  :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end

  def update
    if @import.update_attributes(import_params)
      render :json => @import
    else
      render :json => @import, :status => :unprocessable_entity, :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end

  def destroy
    if @import.destroy
      render :json => @import
    else
      render :json => { :errors => [{:title => "Import error", :detail => "Error deleting import"}] },:status => :unprocessable_entity
    end
  end

  def start
    @import.prepare_run
    Spawnling.new do
      @import.import!({:async => true})
    end
    render :json => @import
  end

  def maps
    sort_key = "created_at"
    sort_order = "desc"
    sort_order = "asc" if index_params[:sort_order] == "asc"

    order_options = "#{sort_key} #{sort_order}"
     paginate_options = {
      :page => index_params[:page],
      :per_page => index_params[:per_page] || 50
    }
    @maps = @import.maps.order(order_options).paginate(paginate_options)
    render :json => @maps
  end
  
  def index
    sort_order = "desc"
    sort_order = "asc" if index_params[:sort_order] == "asc"
    sort_key = %w(id category user_id status created_at finished_at).detect{|f| f == (index_params[:sort_key])}
    sort_key = sort_key || "created_at"

    order_options = "#{sort_key} #{sort_order}"
    
    paginate_options = {
      :page => index_params[:page],
      :per_page => index_params[:per_page] || 50
    }
    
    @imports = Import.order(order_options).paginate(paginate_options)
    render :json => @imports, :index => true
  end
  
  
  private
  def index_params
    params.permit(:page, :per_page, :sort_key, :sort_order, :format)
  end
  
  def import_params
    params.require(:data).require(:attributes).permit(:category, :save_layer)
  end

  def find_import
    @import = Import.find(params[:id])
  end
  
  
end
