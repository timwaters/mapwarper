class Api::V1::GcpsController < Api::V1::ApiController
  before_filter :authenticate_user!, :except =>[:show, :index]
  before_filter :check_editor_role,  :only =>  [:add_many] 
  before_filter :find_gcp,           :only =>  [:show, :update, :destroy]
 
  before_filter :validate_jsonapi_type,:only => [:create, :update]
  
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_param_error
 
  def show
    render :json => @gcp
  end
  
  def create
    @gcp = Gcp.new(gcp_params)
    if @gcp.save
      render :json => @gcp, :status => :created
    else
      render :json => @gcp, :status => :unprocessable_entity, :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end
  

  def update
    if @gcp.update_attributes(gcp_params)
      render :json => @gcp
    else
      render :json => @gcp, :status => :unprocessable_entity, :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end
    
  def destroy
    if @gcp.destroy
      render :json => @gcp
    else
      render :json => @gcp, :status => :unprocessable_entity,  :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end
  
  #note: call /maps/:id/gcps to get gcps with error
  def index
    
    map_conditions = nil
    if index_params[:map_id]
      map = Map.find(index_params[:map_id])
      map_conditions = {map_id: map.id}
    end

    #sort / order 
    sort_order = "desc"
    sort_order = "asc" if index_params[:sort_order] == "asc"
    sort_key = %w(map_id created_at updated_at lat lon x y).detect{|f| f == (index_params[:sort_key])}
    sort_key = sort_key || "updated_at" if sort_order == "desc"
    if sort_order == "desc"
      sort_nulls = " NULLS LAST"
    else
      sort_nulls = " NULLS FIRST"
    end
  
    order_options = "#{sort_key} #{sort_order} #{sort_nulls}"
    
    #pagination
    paginate_options = {
      :page => index_params[:page],
      :per_page => index_params[:per_page] || 50
    }
    
    @gcps = Gcp.where(map_conditions).order(order_options).paginate(paginate_options)

    render :json => @gcps, :meta => {
      "total_entries" => @gcps.total_entries,
      "total_pages"   => @gcps.total_pages}
  end
    
  # Adds Many GCPS to Multiple Maps
  # Editor only
  # Expects a JSON strong
  # POST with mapid
  # json format: {"gcps":[{"mapid":26,"x":1.2,"y":2.2, "lat":11.1, "lon":21.1},{"mapid":1234,"x":1.2,"y":2.2, "lat":11.1, "lon":21.1}....
  # curl -X POST http://localhost:3000/gcps/add_many.json -H "Content-Type: application/json" -d '{"gcps":[{"mapid":26,"x":1.2,"y":2.2},{"mapid":21,"x":1.2,"y":2.2}]}' --user email@example.com:pass
 def add_many
    gcps = nil
    
    if params[:gcps]
      gcps = Gcp.add_many_from_json(params[:gcps])
    end
    
    render :json => gcps
  end
  
 
  private
  
  def gcp_params
    params.require(:data).require(:attributes).permit(:x, :y, :lat, :lon, :map_id)
  end
  

  def index_params
    params.permit(:page, :per_page, :query, :field, :sort_key, :sort_order, :field,  :format, :map_id)
  end
  
  def find_gcp
    @gcp = Gcp.find(params[:id])
  end
  


end
