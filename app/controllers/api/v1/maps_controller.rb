class Api::V1::MapsController < Api::V1::ApiController
  before_filter :authenticate_user!,       :except=>[:show, :index, :status, :gcps] 
  before_filter :check_administrator_role, :only => [:publish, :unpublish]
  before_filter :check_editor_role,        :only => [:update, :destroy]
  before_filter :find_map, :only => [:show, :update, :destroy, :gcps, :rectify, :mask, :delete_mask, :crop, :mask_crop_rectify, :publish, :unpublish, :status ]
  
  before_filter :validate_jsonapi_type,:only => [:create, :update]
  
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_param_error

  
  def show
    if request.format == "geojson"
      render :json  => @map, :serializer => MapGeoSerializer, :adapter => :attributes
     return
   end
    render :json  => @map, :include => ['layers', 'owner']
  end

  def create
    if !map_params[:page_id].blank?
    
      if map_params[:page_id] =~ /\A\d+\Z/
        @map = Map.new_from_wiki(map_params[:page_id])
      else
        @map = Map.new
        @map.errors.add(:page_id, 'is not a number')
        render :json => @map, :status => :unprocessable_entity, :serializer => ActiveModel::Serializer::ErrorSerializer 
        return
      end
    
    else
      @map = Map.new(map_params)
    end

    if user_signed_in?
      @map.owner = current_user
      @map.users << current_user
    end

    if @map.save
      render :json => @map, :status => :created
    else
      render :json => @map, :status => :unprocessable_entity, :serializer => ActiveModel::Serializer::ErrorSerializer 
    end

  end

  def update
    if @map.update_attributes(map_params)
      render :json => @map
    else
      render :json => @map, :status => :unprocessable_entity, :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end

  def destroy
    if @map.destroy
      render :json => @map
    end
  end

  def gcps
    render :json  => @map.gcps_with_error, :meta => {"map-error"=>@map.error}
  end
  
  #patch warp
  def rectify
    resample_param = params[:resample_options]
    transform_param = params[:transform_options]
    masking_option = params[:mask]
    resample_option = ""
    transform_option = ""
    case transform_param
    when "auto"
      transform_option = ""
    when "p1"
      transform_option = " -order 1 "
    when "p2"
      transform_option = " -order 2 "
    when "p3"
      transform_option = " -order 3 "
    when "tps"
      transform_option = " -tps "
    else
      transform_option = ""
    end

    case resample_param
    when "near"
      resample_option = " -rn "
    when "bilinear"
      resample_option = " -rb "
    when "cubic"
      resample_option = " -rc "
    when "cubicspline"
      resample_option = " -rcs "
    when "lanczos" #its very very slow
      resample_option = " -rn "
    else
      resample_option = " -rn"
    end
    
    use_mask = params[:use_mask]
    if @map.gcps.hard.size.nil? || @map.gcps.hard.size < 3
      render :json => { :errors => [{:title => "Not enough gcps", :detail => "Map needs at least 3 control points to rectify"}] },:status => :unprocessable_entity
      return false
    end
    if @map.status == :warping
      render :json => { :errors => [{:title => "Map busy", :detail => "Map currently being rectified. Try again later."}] },:status => :unprocessable_entity
      return false
    end
     
    @map.warp! transform_option, resample_option, use_mask
    
    if user_signed_in?
      begin
        @map.update_commons_page(current_user)
      rescue => e
        logger.error "ERROR with update commons page Map:#{@map.id}"
        logger.error e.inspect
      end
    end
    
    render :json => @map
  end

  #post saves the mask
  def mask
    if @map.save_mask(params[:output])
      render :json => @map
    else
      render :json => { :errors => [{:title => "Mask error", :detail => "Error with saving mask"}] },:status => :unprocessable_entity
    end
  end
  
  def delete_mask
    if @map.delete_mask
      render :json => @map
    else
      render :json => {:errors =>  [{:title => "Mask error", :detail => "Error with deleting mask"}] },:status => :unprocessable_entity
    end
  end
  
  def crop
    unless  File.exists?(@map.masking_file_gml)
      render :json => {:errors => [{:title => "Mask error", :detail => "Mask file not found"}]},:status => :unprocessable_entity
      return false
    end
    if @map.mask!
      render :json => @map
    else
      render :json => { :errors => [{:title => "Mask error", :detail => "Error with cropping map"}] },:status => :unprocessable_entity
    end
  end
    
  #1. save mask
  #2. mask map
  #3. forward on to rectify
  def mask_crop_rectify
    if @map.save_mask(params[:output]) && @map.mask!
      params[:use_mask] = "true"
      rectify
    else
      render :json => { :errors => [{:title => "Saving and masking error", :detail => "Error with saving and masking map"}] },:status => :unprocessable_entity
    end
  end
  
  def publish
    unless @map.status == :warped
      render :json => {:errors => [{:title =>"Map not warped", :detail => "Map is not warped so cannot be published"}]},:status => :unprocessable_entity
      return false
    end
    if @map.publish
      render :json => @map
    else
      render :json => {:errors => [{:title => "Publish error", :detail => "Error with publishing map" }]},:status => :unprocessable_entity
    end
  end
  
  def unpublish
    unless @map.status == :published
      render :json => {:errors => [{:title => "Publish error", :detail => "Map is not published so cannot be unpublished"}] },:status => :unprocessable_entity
      return false
    end
    if @map.unpublish
      render :json => @map
    else
      render :json => {:errors => [{:title => "Publish error", :detail => "Error with unpublishing map"}] },:status => :unprocessable_entity
    end
  end
  
  def status
    render :text => @map.status
  end
  
  #params: page, per_page, query, field, sort_key, sort_order, field, show_warped, bbox, operation
  def index

    #if being called from layer#maps 
    layer_conditions = nil
    if index_params[:layer_id]
      layer = Layer.find(index_params[:layer_id])
      layer_conditions = {id: layer.maps.map(&:id)}
    end
    
    #sort / order 
    sort_order = "desc"
    sort_order = "asc" if index_params[:sort_order] == "asc"
    sort_key = %w(title status created_at updated_at).detect{|f| f == (index_params[:sort_key])}
    sort_key = sort_key || "updated_at"
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

    #query
    query = index_params[:query]
    
    field = %w(tags title description status publisher authors).detect{|f| f == (index_params[:field])}
    field = field || "title"
    if query && query.strip.length > 0 && field
      query_options = ["#{field}  ~* ?", '(:punct:|^|)'+query+'([^A-z]|$)']
    else
      query_options = nil
    end

    #show_warped
    warped_options = nil
    if index_params[:show_warped] == "1"
      warped_options = { :status => [Map.status(:warped), Map.status(:published)], :map_type => Map.map_type(:is_map)  }
    end
    
    #bbox
    bbox_conditions = nil
    sort_geo = nil
    
    #extents = [-74.1710,40.5883,-73.4809,40.8485] #NYC
    if params[:bbox] && params[:bbox].split(',').size == 4
      extents  = nil
      begin
        extents = params[:bbox].split(',').collect {|i| Float(i)}
      rescue ArgumentError
        logger.debug "arg error with bbox, setting extent to defaults"
        #TODO send back error message here instead of defaults
      end
      if extents 
        bbox_poly_ary = [
          [ extents[0], extents[1] ],
          [ extents[2], extents[1] ],
          [ extents[2], extents[3] ],
          [ extents[0], extents[3] ],
          [ extents[0], extents[1] ]
        ]
        bbox_polygon = GeoRuby::SimpleFeatures::Polygon.from_coordinates([bbox_poly_ary], -1).as_ewkt
        if params[:operation] == "within"
          bbox_conditions = ["ST_Within(bbox_geom, ST_GeomFromText('#{bbox_polygon}'))"]
        else
          bbox_conditions = ["ST_Intersects(bbox_geom, ST_GeomFromText('#{bbox_polygon}'))"]
        end
        
        if params[:operation] == "intersect"
          sort_geo = "ABS(ST_Area(bbox_geom) - ST_Area(ST_GeomFromText('#{bbox_polygon}'))) ASC"
        else
          sort_geo ="ST_Area(bbox_geom) DESC"
        end
      end
      
    end
    
    
    @maps = Map.all.where(layer_conditions).where(warped_options).where(query_options).where(bbox_conditions).order(order_options).order(sort_geo).paginate(paginate_options)
    
    if request.format == "geojson"
      render :json  => @maps, :each_serializer => MapGeoSerializer, :adapter => :attributes
      return
    end
    #ActiveSupport.escape_html_entities_in_json = false
    render :json => @maps, 
      :include => ['layers', 'owner'],
      :meta => {"total-entries" => @maps.total_entries,
      "total-pages"   => @maps.total_pages}
  end

  private
  def map_params
    params.require(:data).require(:attributes).permit(:title, :description, :page_id)
  end

  def index_params
    params.permit(:page, :per_page, :query, :field, :sort_key, :sort_order, :field, :show_warped, :bbox, :operation, :format, :layer_id, :id)
  end
  
  def find_map
    @map = Map.find(params[:id])
  end


end
