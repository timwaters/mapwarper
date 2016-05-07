class Api::V1::LayersController < Api::V1::ApiController
  #before_filter :authenticate_user!
  #before_filter :check_administrator_role
  before_filter :find_layer, :only => [:show]
  
  rescue_from ActionController::ParameterMissing, with: :missing_param_error
  def missing_param_error(exception)
    render :json => { :error => exception.message },:status => :unprocessable_entity
  end

  def show
    render :json => @layer
  end
  
 

  #create
  
  #update
  
  #delete
  
  #visibility
    
  #remove map
     
  #index 
  def index
    
    #map_conditions
    #maps/map_id/layers 
    map_conditions = nil
    if index_params[:map_id]
      map = Map.find(index_params[:map_id])
      map_conditions = {id: map.layers.map(&:id)}
    end
    
    #sort / order 
    sort_order = "desc"
    sort_order = "asc" if index_params[:sort_order] == "asc"
    sort_key = %w(name created_at updated_at percent).detect{|f| f == (index_params[:sort_key])}
    sort_key = sort_key || "updated_at" if sort_order == "desc"
    if sort_order == "desc"
      sort_nulls = " NULLS LAST"
    else
      sort_nulls = " NULLS FIRST"
    end
  
    order_options = "#{sort_key} #{sort_order} #{sort_nulls}"
  
    #select percent
    select = "*"
    select_conditions = nil
    if sort_key == "percent"
      select = "*, round(rectified_maps_count::float / maps_count::float * 100) as percent"
      select_conditions = "maps_count > 0"
    end
    
    #pagination
    paginate_options = {
      :page => index_params[:page],
      :per_page => index_params[:per_page] || 50
    }
  
    #query
    query = index_params[:query]
    field = %w(name description).detect{|f| f== (params[:field])}
    field = field || "name"
    query_conditions = nil
    if query && query.strip.length > 0
      query_conditions =   ["#{field}  ~* ?", '(:punct:|^|)'+query+'([^A-z]|$)']
    end
    
    @layers = Layer.select(select).where(select_conditions).where(map_conditions).where(query_conditions).order(order_options).paginate(paginate_options)
    
    render :json => @layers, :meta => {
      "total-entries" => @layers.total_entries,
      "total-pages"   => @layers.total_pages}
  end
    
  #maps
  
  
  
  
  private
  
  def layer_params
    params.require(:layer).permit(:name, :description, :source_uri, :depicts_year)
  end

  def index_params
    params.permit(:page, :per_page, :query, :field, :sort_key, :sort_order, :field,  :bbox, :operation, :format, :map_id)
  end
  
  def find_layer
    @layer = Layer.find(params[:id])
  end
  


end
