class Api::V1::MapsController < Api::V1::ApiController
  #before_filter :authenticate_user!
  #before_filter :check_administrator_role
  before_filter :find_map, :only => [:show, :update, :destroy, :gcps, :rectify, :mask, :delete_mask, :crop, :mask_crop_rectify, :publish, :unpublish ]
  
  rescue_from ActionController::ParameterMissing, with: :missing_param_error
  def missing_param_error(exception)
    render :json => { :error => exception.message },:status => :unprocessable_entity
  end
  
  def show
    #puts current_user.inspect
    render :json  => @map, :meta => {:foo => :bar}
  end

  def create
    if !map_params["page_id"].blank?
    
      if map_params["page_id"] =~ /\A\d+\Z/
        @map = Map.new_from_wiki(map_params["page_id"])
      else
        render :json => {:errors => {:title => "page_id parameter is not a number"}}, :status => :unprocessable_entity
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
      render :json => @map.errors, :status => :unprocessable_entity  
    end

  end

  def update
    if @map.update_attributes(map_params)
      render :json => @map
    else
      render :json => @map.errors, :status => :unprocessable_entity
    end
  end

  def destroy
    if @map.destroy
      render :json => @map
    end
  end

  def gcps
    render :json  => @map.gcps
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
      render :json => { :error => "Map needs at least 3 control points to rectify" },:status => :unprocessable_entity
      return false
    end
    if @map.status == :warping
      render :json => { :error => "Map currently being rectified. Try again later." },:status => :unprocessable_entity
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
      render :json => { :error => "Error with saving mask" },:status => :unprocessable_entity
    end
  end
  
  def delete_mask
    if @map.delete_mask
      render :json => @map
    else
      render :json => { :error => "Error with deleting mask" },:status => :unprocessable_entity
    end
  end
  
  def crop
    unless  File.exists?(@map.masking_file_gml)
      render :json => {:error => "Mask file not found"},:status => :unprocessable_entity
      return false
    end
    if @map.mask!
      render :json => @map
    else
      render :json => { :error => "Error with cropping map" },:status => :unprocessable_entity
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
      render :json => { :error => "Error with saving and masking map" },:status => :unprocessable_entity
    end
  end
  
  def publish
    unless @map.status == :warped
      render :json => {:error => "Map is not warped so cannot be published" },:status => :unprocessable_entity
      return false
    end
    if @map.publish
      render :json => @map
    else
      render :json => {:error => "Error with publishing map" },:status => :unprocessable_entity
    end
  end
  
  def unpublish
    unless @map.status == :published
      render :json => {:error => "Map is not published so cannot be unpublished" },:status => :unprocessable_entity
      return false
    end
    if @map.unpublish
      render :json => @map
    else
      render :json => {:error => "Error with unpublishing map" },:status => :unprocessable_entity
    end
  end
  
  #params: page, per_page, query, field, sort_key, sort_order, field, show_warped, bbox, operation
  def index

    #sort / order 
    sort_order = "desc"
    sort_order = "asc" if index_params[:sort_order] == "asc"
    sort_key = %w(title status created_at updated_at).detect{|f| f == (index_params[:sort_key])}
    sort_key = sort_key || "updated_at"
    order_options = "#{sort_key} #{sort_order}"
  
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
    
   
    @maps = Map.all.where(warped_options).where(query_options).where(bbox_conditions).paginate(paginate_options).order(order_options).order(sort_geo)
     
    #ActiveSupport.escape_html_entities_in_json = false
    render :json => @maps, 
      :meta => {"total-entries" => @maps.total_entries,
      "total-pages"   => @maps.total_pages}
  end

  private
  def map_params
    #TODO serialize from jsonapi 
    #puts params.inspect
    #ActiveModelSerializers::Deserialization.jsonapi_parse(params)
    params.require(:map).permit(:title, :description, :page_id)
  end

  def index_params
    params.permit(:page, :per_page, :query, :field, :sort_key, :sort_order, :field, :show_warped, :bbox, :operation, :format)
  end
  
  def find_map
    @map = Map.find(params[:id])
  end
  


end
