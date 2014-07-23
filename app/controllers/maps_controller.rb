class MapsController < ApplicationController

  layout 'mapdetail', :only => [:show, :edit, :preview, :warp, :clip, :align, :activity, :warped, :export, :metadata, :comments]
  
  before_filter :find_map_if_available,
    :except => [:show, :index, :wms, :tile, :mapserver_wms, :warp_aligned, :status, :new, :create, :update, :edit, :tag, :geosearch]

  before_filter :check_link_back, :only => [:show, :warp, :clip, :align, :warped, :export, :activity]
  before_filter :check_if_map_is_editable, :only => [:edit, :update]
  before_filter :check_if_map_can_be_deleted, :only => [:destroy, :delete]
  skip_before_filter :verify_authenticity_token, :only => [:save_mask, :delete_mask, :save_mask_and_warp, :mask_map, :rectify, :set_rough_state, :set_rough_centroid]

  helper :sort
  include SortHelper
  
  def new
    @map = Map.new
    @html_title = "Upload a new map to "
    @max_size = Map.max_attachment_size
    if Map.max_dimension
      @upload_file_message  = " It may resize the image if it's too large (#{Map.max_dimension}x#{Map.max_dimension}) "
    else
      @upload_file_message = ""
    end

    respond_to do |format|
      format.html{ render :layout =>'application' }  # new.html.erb
      format.xml  { render :xml => @map }
    end
  end
  
  def create
    @map = Map.new(map_params)

    if user_signed_in?
      @map.owner = current_user
      @map.users << current_user
    end

    respond_to do |format|
      if @map.save
        flash[:notice] = 'Map was successfully created.'
        format.html { redirect_to(@map) }
        format.xml  { render :xml => @map, :status => :created, :location => @map }
      else
        format.html { render :action => "new", :layout =>'application' }
        format.xml  { render :xml => @map.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @current_tab = :edit
    @selected_tab = 1
    @html_title = "Editing Map #{@map.title} on"
    choose_layout_if_ajax
    respond_to do |format|
      format.html {} #{ render :layout =>'application' }  # new.html.erb
      format.xml  { render :xml => @map }
    end
  end
  
  def update
   
    if @map.update_attributes(map_params)
      flash.now[:notice] = 'Map was successfully updated.'
    else
      flash.now[:error] = 'There was an error updating the map' 
    end
    
    if request.xhr?
      @xhr_flag = "xhr"
      render :action => "edit", :layout => "tab_container"
    else
      respond_to do |format|
        format.html { redirect_to map_path }
        format.xml  { render :xml => @map.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  def delete
    respond_to do |format|
      format.html {render :layout => 'application'}
    end
  end
  
  #only editors or owners of maps
  def destroy
    if @map.destroy
      flash[:notice] = "Map deleted!"
    else
      flash[:notice] = "Map wasnt deleted"
    end
    respond_to do |format|
      format.html { redirect_to(maps_url) }
      format.xml  { head :ok }
    end
  end
  
  def status
    map = Map.find(params[:id])
    if map.status.nil?
      sta = "loading"
    else
      sta = map.status.to_s
    end
    render :text =>  sta
  end
  
  def show

    @current_tab = "show"
    @selected_tab = 0
    @disabled_tabs =[]
    @map = Map.find(params[:id])
    @html_title = "Viewing Map "+@map.id.to_s

    if @map.status.nil? || @map.status == :unloaded
      @mapstatus = "unloaded"
    else
      @mapstatus = @map.status.to_s
    end

    #
    # Not Logged in users
    #
    if !user_signed_in?
      @disabled_tabs = ["warp", "edit", "clip", "align", "activity"]
      
      if @map.status.nil? or @map.status == :unloaded or @map.status == :loading
        @disabled_tabs += ["warped"]
      end
      
      flash.now[:notice] = "You may need to %s to start editing the map"
      flash.now[:notice_item] = ["log in", new_session_path]
      
      if request.xhr?
        @xhr_flag = "xhr"
        render :layout => "tab_container"
      else
        respond_to do |format|
          format.html 
          #format.kml {render :action => "show_kml", :layout => false}
          #format.rss {render :action=> 'show'}
          #format.xml {render :xml => @map.to_xml(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]) }
          #format.json {render :json =>{:stat => "ok", :items => @map.to_a}.to_json(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]), :callback => params[:callback] }
        end
      end
      
      return #stop doing anything more
    end

    #End doing stuff for not logged in users.


    #
    # Logged in users
    #
    unless user_signed_in? and (current_user.own_this_map?(params[:id])  or current_user.has_role?("editor"))
      @disabled_tabs += ["edit"]  #don't allow anyone else to edit it, unless you are an editor
      if @map.published?
        @disabled_tabs += ["warp", "clip", "align"]  #dont show any others unless you're an editor
      end
    end

    @title = "Viewing original map. "

    if !@map.warped_or_published?
      @title += "This map has not been rectified yet."
    end
    
    choose_layout_if_ajax

    respond_to do |format|
      format.html
      # format.kml {render :action => "show_kml", :layout => false}
      # format.xml {render :xml => @map.to_xml(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid])  }
      #  format.json {render :json =>{:stat => "ok", :items => @map.to_a}.to_json(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]), :callback => params[:callback] }
    end
    
    
  end
  
  def index
    sort_init('updated_at', {:default_order => "desc"})
    
    sort_update
    @show_warped = params[:show_warped]
    request.query_string.length > 0 ?  qstring = "?" + request.query_string : qstring = ""
    
    set_session_link_back url_for(:controller=> 'maps', :action => 'index',:skip_relative_url_root => false, :only_path => false )+ qstring
    
    @query = params[:query]
    
    @field = %w(tags title description status publisher authors).detect{|f| f == (params[:field])}
    
    unless @field == "tags"
      
      @field = "title" if @field.nil?
      
      #we'll use POSIX regular expression for searches    ~*'( |^)robinson([^A-z]|$)' and to strip out brakets etc  ~*'(:punct:|^|)plate 6([^A-z]|$)';
      if @query && @query.strip.length > 0 && @field
        conditions = ["#{@field}  ~* ?", '(:punct:|^|)'+@query+'([^A-z]|$)']
      else
        conditions = nil
      end
      
      if params[:sort_order] && params[:sort_order] == "desc"
        sort_nulls = " NULLS LAST"
      else
        sort_nulls = " NULLS FIRST"
      end
      @per_page = params[:per_page] || 10
      paginate_params = {
        :page => params[:page],
        :per_page => @per_page
      }
      order_options = sort_clause + sort_nulls
      where_options = conditions
        #order('name').where('name LIKE ?', "%#{search}%").paginate(page: page, per_page: 10)

      if @show_warped == "1"
        @maps = Map.warped.are_public.where(where_options).order(order_options).paginate(paginate_params)
      elsif @show_warped == "1" && (user_signed_in? and current_user.has_role?("editor"))
        @maps = Map.warped.where(where_options).order(order_options).paginate(paginate_params)
      elsif  @show_warped != "1" && (user_signed_in? and current_user.has_role?("editor"))
        @maps = Map.where(where_options).order(order_options).paginate(paginate_params)
      else
        @maps = Map.are_public.where(where_options).order(order_options).paginate(paginate_params)
      end
      
      @html_title = "Browse Maps"
      if request.xhr?
        render :action => 'index.rjs'
      else
        respond_to do |format|
          format.html{ render :layout =>'application' }  # index.html.erb
          format.xml  { render :xml => @maps.to_xml(:root => "maps", :except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]) {|xml|
              xml.tag!'stat', "ok"
              xml.tag!'total-entries', @maps.total_entries
              xml.tag!'per-page', @maps.per_page
              xml.tag!'current-page',@maps.current_page} }
          
          format.json { render :json => {:stat => "ok",
              :current_page => @maps.current_page,
              :per_page => @maps.per_page,
              :total_entries => @maps.total_entries,
              :total_pages => @maps.total_pages,
              :items => @maps.to_a}.to_json(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid], :methods => :depicts_year) , :callback => params[:callback]
          }
        end
      end
    else
      redirect_to :action => 'tag', :id => @query
    end
  end
  
  def geosearch
    
  end
  
  
  include Mapscript if require 'mapscript'

  def wms
    
    @map = Map.find(params[:id])
    #status is additional query param to show the unwarped wms
    status = params["STATUS"].to_s.downcase || "unwarped"
    ows = Mapscript::OWSRequest.new
    
    ok_params = Hash.new
    # params.each {|k,v| k.upcase! } frozen string error
    params.each {|k,v| ok_params[k.upcase] = v }
    [:request, :version, :transparency, :service, :srs, :width, :height, :bbox, :format, :srs].each do |key|
      ows.setParameter(key.to_s, ok_params[key.to_s.upcase]) unless ok_params[key.to_s.upcase].nil?
    end
    
    ows.setParameter("VeRsIoN","1.1.1")
    ows.setParameter("STYLES", "")
    ows.setParameter("LAYERS", "image")
    ows.setParameter("COVERAGE", "image")
    
    mapsv = Mapscript::MapObj.new(File.join(Rails.root, '/lib/mapserver/wms.map'))
    projfile = File.join(Rails.root, '/lib/proj')
    mapsv.setConfigOption("PROJ_LIB", projfile)
    #map.setProjection("init=epsg:900913")
    mapsv.applyConfigOptions
    rel_url_root =  (ActionController::Base.relative_url_root.blank?)? '' : ActionController::Base.relative_url_root
    mapsv.setMetaData("wms_onlineresource",
      "http://" + request.host_with_port + rel_url_root + "/maps/wms/#{@map.id}")
    
    raster = Mapscript::LayerObj.new(mapsv)
    raster.name = "image"
    raster.type = Mapscript::MS_LAYER_RASTER
    
    if status == "unwarped"
      raster.data = @map.unwarped_filename
      
    else #show the warped map
      raster.data = @map.warped_filename
    end
    
    raster.status = Mapscript::MS_ON
    raster.dump = Mapscript::MS_TRUE
    raster.metadata.set('wcs_formats', 'GEOTIFF')
    raster.metadata.set('wms_title', @map.title)
    raster.metadata.set('wms_srs', 'EPSG:4326 EPSG:3857 EPSG:4269 EPSG:900913')
    #raster.debug = Mapscript::MS_TRUE
    raster.setProcessingKey("CLOSE_CONNECTION", "ALWAYS")
    
    Mapscript::msIO_installStdoutToBuffer
    result = mapsv.OWSDispatch(ows)
    content_type = Mapscript::msIO_stripStdoutBufferContentType || "text/plain"
    result_data = Mapscript::msIO_getStdoutBufferBytes
    
    send_data result_data, :type => content_type, :disposition => "inline"
    Mapscript::msIO_resetHandlers
    
    
  end
  
  def tile
    x = params[:x].to_i
    y = params[:y].to_i
    z = params[:z].to_i
    #for Google/OSM tile scheme we need to alter the y:
    y = ((2**z)-y-1)
    #calculate the bbox
    params[:bbox] = get_tile_bbox(x,y,z)
    #build up the other params
    params[:status] = "warped"
    params[:format] = "image/png"
    params[:service] = "WMS"
    params[:version] = "1.1.1"
    params[:request] = "GetMap"
    params[:srs] = "EPSG:900913"
    params[:width] = "256"
    params[:height] = "256"
    #call the wms thing
    wms
    
  end
  
  
  private
  
  #veries token but only for the html view, turned off for xml and json calls - these calls would need to be authenticated anyhow.
  def semi_verify_authenticity_token
    unless request.format.xml? || request.format.json?
      verify_authenticity_token
    end
  end

  def set_session_link_back link_url
    session[:link_back] = link_url
  end

  def check_link_back
    @link_back = session[:link_back]
    if @link_back.nil?
      @link_back = url_for(:action => 'index')
    end
  
    session[:link_back] = @link_back
  end

  #only allow deleting by a user if the user owns it
  def check_if_map_can_be_deleted
    if user_signed_in? and (current_user.own_this_map?(params[:id])  or current_user.has_role?("editor"))
      @map = Map.find(params[:id])
    else
      flash[:notice] = "Sorry, you cannot delete other people's maps!"
      redirect_to map_path
    end
  end

  def bad_record
    #logger.error("not found #{params[:id]}")
    respond_to do | format |
      format.html do
        flash[:notice] = "Map not found"
        redirect_to :action => :index
      end
      format.json {render :json => {:stat => "not found", :items =>[]}.to_json, :status => 404}
    end
  end

  #only allow editing by a user if the user owns it, or if and editor tries to edit it
  def check_if_map_is_editable
    if user_signed_in? and (current_user.own_this_map?(params[:id])  or current_user.has_role?("editor"))
      @map = Map.find(params[:id])
    elsif Map.find(params[:id]).owner.nil?
      @map = Map.find(params[:id])
    else
      flash[:notice] = "Sorry, you cannot edit other people's maps"
      redirect_to map_path
    end
  end

  def find_map_if_available

    @map = Map.find(params[:id])

    if @map.status.nil? or @map.status == :unloaded or @map.status == :loading 
      redirect_to map_path
    elsif  (!@map.public? and !logged_in?) or((!@map.public? and logged_in?) and !(current_user.own_this_map?(params[:id])  or current_user.has_role?("editor")) )
      redirect_to maps_path
    end
  end
  
  
  def map_params
    params.require(:map).permit!
  end
  
  def choose_layout_if_ajax
    if request.xhr?
      @xhr_flag = "xhr"
      render :layout => "tab_container"
    end
  end
  
end
