class MapsController < ApplicationController
   layout 'mapdetail', :only => [:show, :edit, :preview, :warp, :clip, :align, :activity, :warped, :export, :metadata, :comments]
  #before_filter :login_required, :only => [:destroy, :delete]
  before_filter :login_or_oauth_required, :only => [:new, :create, :edit, :update, :destroy, :delete, :warp, :rectify, :clip, :align,
 :warp_align, :mask_map, :delete_mask, :save_mask, :save_mask_and_warp, :set_rough_state, :set_rough_centroid ]
  before_filter :check_administrator_role, :only => [:publish]
  before_filter :find_map_if_available,
    :except => [:show, :index, :wms, :tile, :mapserver_wms, :warp_aligned, :status, :new, :create, :update, :edit, :tag, :geosearch]

  before_filter :check_link_back, :only => [:show, :warp, :clip, :align, :warped, :export, :activity]
  before_filter :check_if_map_is_editable, :only => [:edit, :update]
  before_filter :check_if_map_can_be_deleted, :only => [:destroy, :delete]
  
  skip_before_filter :verify_authenticity_token, :only => [:save_mask, :delete_mask, :save_mask_and_warp, :mask_map, :rectify, :set_rough_state, :set_rough_centroid]
  #before_filter :semi_verify_authenticity_token, :only => [:save_mask, :delete_mask, :save_mask_and_warp, :mask_map, :rectify]
  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record



  helper :sort
  include SortHelper

  def choose_layout_if_ajax
    if request.xhr?
      @xhr_flag = "xhr"
      render :layout => "tab_container"
    end
  end

  def get_rough_centroid
    map = Map.find(params[:id])
    respond_to do |format|
      format.json {render :json =>{:stat => "ok", :items => map.to_a}.to_json(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]), :callback => params[:callback]  }
    end
  end
  
  def set_rough_centroid
    map = Map.find(params[:id])
    lon = params[:lon]
    lat = params[:lat]
    zoom = params[:zoom]
    respond_to do |format|
      if map.update_attributes(:rough_lon  => lon, :rough_lat => lat, :rough_zoom => zoom ) && lat && lon
        map.save_rough_centroid(lon, lat)
        format.json {render :json =>{:stat => "ok", :items => map.to_a}.to_json(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]), :callback => params[:callback]
        }
      else
        format.json { render :json => {:stat => "fail", :message => "Rough centroid not set", :items => [], :errors => map.errors.to_a}.to_json, :callback => params[:callback]}
      end
    end
  end

  def get_rough_state
    map = Map.find(params[:id])
    respond_to do |format|
      if map.rough_state
        format.json { render :json => {:stat => "ok", :items => ["id" => map.id, "rough_state" => map.rough_state]}.to_json, :callback => params[:callback]}
      else
        format.json { render :json => {:stat => "fail", :message => "Rough state is null", :items => map.rough_state}.to_json, :callback => params[:callback]}
      end
    end
  end

  def set_rough_state
    map = Map.find(params[:id])
    respond_to do |format|
      if map.update_attributes(:rough_state => params[:rough_state]) && Map::ROUGH_STATE.include?(params[:rough_state].to_sym)
        format.json { render :json => {:stat => "ok", :items => ["id" => map.id, "rough_state" => map.rough_state]}.to_json, :callback => params[:callback] }
      else
        format.json { render :json => {:stat => "fail", :message =>"Could not update state", :errors => map.errors.to_a, :items => []}.to_json , :callback => params[:callback]}
      end
    end
  end


  def comments
    @html_title = "comments"
    @selected_tab = 9
    @current_tab = "comments"
    @comments = @map.comments
    choose_layout_if_ajax
    respond_to do | format |
      format.html {}
    end
  end

  #pass in soft true to get soft gcps
 def gcps
    @map = Map.find(params[:id])
    gcps = @map.gcps_with_error(params[:soft])
    respond_to do |format|
      #format.json { render :json => gcps.to_json(:methods => :error)}
      format.json { render :json => {:stat => "ok", :items => gcps.to_a}.to_json(:methods => :error), :callback => params[:callback]}
      format.xml { render :xml => gcps.to_xml(:methods => :error)}
    end
  end

    require 'yahoo-geoplanet'
  def geosearch
    sort_init 'updated_at'
    sort_update

    extents = [-74.1710,40.5883,-73.4809,40.8485] #NYC

    #TODO change to straight javascript call.
    if params[:place] && !params[:place].blank?
      place_query = params[:place]
      Yahoo::GeoPlanet.app_id = Yahoo_app_id
      geoplanet_result = Yahoo::GeoPlanet::Place.search(place_query, :count => 2)
      if geoplanet_result[0]
        g_bbox =  geoplanet_result[0].bounding_box.map!{|x| x.reverse}
        extents = g_bbox[1] + g_bbox[0]
        render :json => extents.to_json
        return
      else
        render :json => extents.to_json
        return
      end
    end

    if params[:bbox] && params[:bbox].split(',').size == 4
      begin
        extents = params[:bbox].split(',').collect {|i| Float(i)}
      rescue ArgumentError
        logger.debug "arg error with bbox, setting extent to defaults"
      end
    end
    @bbox = extents.join(',')

    if extents
      bbox_poly_ary = [
        [ extents[0], extents[1] ],
        [ extents[2], extents[1] ],
        [ extents[2], extents[3] ],
        [ extents[0], extents[3] ],
        [ extents[0], extents[1] ]
      ]

      bbox_polygon = Polygon.from_coordinates([bbox_poly_ary], -1).as_ewkt
      if params[:operation] == "within"
        conditions = ["ST_Within(bbox_geom, ST_GeomFromText('#{bbox_polygon}'))"]
      else
        conditions = ["ST_Intersects(bbox_geom, ST_GeomFromText('#{bbox_polygon}'))"]
      end

    else
      conditions = nil
    end


    if params[:sort_order] && params[:sort_order] == "desc"
      sort_nulls = " NULLS LAST"
    else
      sort_nulls = " NULLS FIRST"
    end


      @operation = params[:operation]

    if @operation == "intersect"
      sort_geo = "ABS(ST_Area(bbox_geom) - ST_Area(ST_GeomFromText('#{bbox_polygon}'))) ASC,  "
    else
      sort_geo ="ST_Area(bbox_geom) DESC ,"
    end

    paginate_params = {
      :select => "bbox, title, description, updated_at, id",
      :page => params[:page],
      :per_page => 20,
      :order => sort_geo + sort_clause + sort_nulls,
      :conditions => conditions
    }
    @maps = Map.warped.paginate(paginate_params)
    @jsonmaps = @maps.to_json # (:only => [:bbox, :title, :id, :nypl_digital_id])
    respond_to do |format|
      format.html{ render :layout =>'application' }
      #format.json { render :json => @maps.to_json(:stat => "ok")}
      format.json { render :json => {:stat => "ok",
        :current_page => @maps.current_page,
        :per_page => @maps.per_page,
        :total_entries => @maps.total_entries,
        :total_pages => @maps.total_pages,
        :items => @maps.to_a}.to_json , :callback => params[:callback]}
    end
  end

  def export
    @current_tab = "export"
    @selected_tab = 6
    @html_title = "Export Map" + @map.id.to_s
    unless @map.warped_or_published? && @map.map_type == :is_map
      flash.now[:notice] = "Map needs to be rectified before being able to be exported"
    end
    choose_layout_if_ajax
    respond_to do | format |
      format.html {}
      format.tif {  send_file @map.warped_filename, :x_sendfile => (RAILS_ENV != "development") }
      format.png  { send_file @map.warped_png, :x_sendfile => (RAILS_ENV != "development") }
      format.aux_xml { send_file @map.warped_png_aux_xml,:x_sendfile => (RAILS_ENV != "development") }
    end
  end


  def map_type
    @map = Map.find(params[:id])
    map_type = params[:map][:map_type]
    if Map::MAP_TYPE.include? map_type.to_sym
      @map.update_map_type(map_type)
    end
    if Layer.exists?(params[:layerid].to_i)
      @layer = Layer.find(params[:layerid].to_i)
      @maps = @layer.maps.paginate(:per_page => 30, :page => 1, :order => :map_type)
    end
    unless request.xhr?
      render :text => "Map has changed. Map type: "+@map.map_type.to_s
    end
  end

 def clip
    #TODO delete current_tab
    @current_tab = "clip"
    @selected_tab = 3
    @html_title = "Cropping Map "+ @map.id.to_s
    @gml_exists = "false"
    if File.exists?(@map.masking_file_gml+".ol")
      @gml_exists = "true"
    end
    choose_layout_if_ajax
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
        :per_page => @per_page,
        :order => sort_clause + sort_nulls,
        :conditions => conditions
      }

      if @show_warped == "1"
        @maps = Map.warped.public.paginate(paginate_params)
      elsif @show_warped == "1" && (logged_in? and current_user.has_role?("editor"))
        @maps = Map.warped.paginate(paginate_params)
      elsif  @show_warped != "1" && (logged_in? and current_user.has_role?("editor"))
        @maps = Map.paginate(paginate_params)
      else
        @maps = Map.public.paginate(paginate_params)
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
          :items => @maps.to_a}.to_json(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]) , :callback => params[:callback]
        }
        end
      end
   else
     redirect_to :action => 'tag', :id => @query
   end
  end

  def tag
    sort_init('updated_at', {:default_order => "desc"})
    sort_update
    @tags = params[:id] || @query
    @html_title = "Maps tagged with #{@tags} on "
    @maps = Map.public.paged_find_tagged_with(
      @tags,
      :page => params[:page],
      :per_page => 20,
      :order => sort_clause)
    respond_to do |format|
      format.html{ render :layout =>'application' }  # index.html.erb
      format.xml  { render :xml => @maps }
      format.rss  { render  :layout => false }
     end
  end

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
    @map = Map.new(params[:map])

    if logged_in?
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
    #@map = Map.find(params[:id])
    
    if @map.update_attributes(params[:map])
      flash.now[:notice] = 'Map was successfully updated.'
    else

    end

    if request.xhr?
      @xhr_flag = "xhr"
      render :action => "edit", :layout => "tab_container"
    else
      respond_to do |format|
        format.html { render :action => "edit" }
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

  def thumb
     map = Map.find(params[:id])
     thumb = map.upload.url(:thumb)
     redirect_to thumb
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
    if !logged_in?
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
          format.html #
          format.kml {render :action => "show_kml", :layout => false}
          format.rss {render :action=> 'show'}
           format.xml {render :xml => @map.to_xml(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid])
}
           format.json {render :json =>{:stat => "ok", :items => @map.to_a}.to_json(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]), :callback => params[:callback]
}
        end
      end
      return #stop doing anything more
    end

    #End doing stuff for not logged in users.


    #
    # Logged in users
    unless logged_in? and (current_user.own_this_map?(params[:id])  or current_user.has_role?("editor"))
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
      format.kml {render :action => "show_kml", :layout => false}
      format.xml {render :xml => @map.to_xml(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid])
      }
      format.json {render :json =>{:stat => "ok", :items => @map.to_a}.to_json(:except => [:content_type, :size, :bbox_geom, :uuid, :parent_uuid, :filename, :parent_id,  :map, :thumbnail, :rough_centroid]), :callback => params[:callback] }
    end
  end

 
  #should check for admin only
  def publish
    if params[:to] == "publish" && @map.status == :warped
      @map.publish
    elsif params[:to] == "unpublish" && @map.status == :published
      @map.unpublish
    end

    flash[:notice] = "Map changed. New Status: " + @map.status.to_s
    redirect_to @map
  end

  def save_mask
    message = @map.save_mask(params[:output])
    respond_to do | format |
      format.html {render :text => message}
      format.js { render :text => message} if request.xhr?
      format.json {render :json => {:stat =>"ok", :message => message}.to_json , :callback => params[:callback]}
    end
  end

  def delete_mask
    message = @map.delete_mask
     respond_to do | format |
       format.html { render :text => message}
       format.js { render :text => message} if request.xhr?
       format.json {render :json => {:stat =>"ok", :message => message}.to_json , :callback => params[:callback]}
    end
   end

  def mask_map
    respond_to do | format |
      if File.exists?(@map.masking_file_gml)
        message = @map.mask!
        format.html { render :text => message }
        format.js { render :text => message} if request.xhr?
        format.json { render :json => {:stat =>"ok", :message => "Map cropped"}.to_json , :callback => params[:callback]}
      else
        message = "Mask file not found"
        format.html { render :text => message  }
        format.js { render :text => message} if request.xhr?
        format.json { render :json => {:stat =>"fail", :message => message}.to_json , :callback => params[:callback]}
      end
    end
  end
  
  def save_mask_and_warp
    logger.debug "save mask and warp"
    @map.save_mask(params[:output])
    unless @map.status == :warping
      @map.mask!
      stat = "ok"
      if @map.gcps.hard.size.nil? || @map.gcps.hard.size < 3
        msg = "Map masked, but it needs more control points to rectify. Click the Rectify tab to add some."
        stat = "fail"
      else
        params[:use_mask] = "true"
        rectify_main
        msg = "Map masked and rectified."
      end
    else
      stat = "fail"
      msg = "Mask saved, but not applied as the map is currently being rectified somewhere else, please try again later."
    end

    respond_to do |format|
      format.json {render :json => {:stat => stat, :message => msg}.to_json , :callback => params[:callback]}
      format.js { render :text => msg } if request.xhr?
    end
  end

  def warped
    @current_tab = "warped"
    @selected_tab = 5
    @html_title = "Viewing Rectfied Map "+ @map.id.to_s
    if @map.warped_or_published? && @map.gcps.hard.size > 2
      @title = "Viewing warped map"
      @other_layers = Array.new
      @map.layers.visible.each do |layer|
        @other_layers.push(layer.id)
      end

    else
      flash.now[:notice] = "Whoops, the map needs to be rectified before you can view it"
    end
    choose_layout_if_ajax
  end

   #just works with NSEW directions at the moment.
  def warp_aligned
    
    align = params[:align]
    append = params[:append]
    destmap = Map.find(params[:destmap])

    if destmap.status.nil? or destmap.status == :unloaded or destmap.status == :loading
      flash.now[:notice] = "Sorry the destination map is not available to be aligned."
      redirect_to :action => "show", :id=> params[:destmap]
    elsif align != "other"

      if params[:align_type]  == "original"
        destmap.align_with_original(params[:srcmap], align, append )
      else
        destmap.align_with_warped(params[:srcmap], align, append )
      end
      flash.now[:notice] = "Map aligned. You can now rectify it!"
      redirect_to :action => "warp", :id => destmap.id
    else
      flash.now[:notice] = "Sorry, only horizontal and vertical alignment are available at the moment."
      redirect_to :action => "align", :id=> params[:srcmap]
    end
  end

  def align
    @html_title = "Align Maps "
    @current_tab = "align"
    @selected_tab = 3

    choose_layout_if_ajax
  end

   def warp
     @current_tab = "warp"
     @selected_tab = 2
     @html_title = "Rectifying Map "+ @map.id.to_s
     @bestguess_places = @map.find_bestguess_places  if @map.gcps.hard.empty?
     @other_layers = Array.new
     @map.layers.visible.each do |layer| 
       @other_layers.push(layer.id)
     end

     @gcps = @map.gcps_with_error 

     choose_layout_if_ajax 
   end




   def rectify
     rectify_main

     respond_to do |format|
       unless @too_few || @fail
         format.js if request.xhr?
         format.html { render :text => @notice_text }
         format.json { render :json=> {:stat => "ok", :message => @notice_text}.to_json, :callback => params[:callback] }
       else
         format.js if request.xhr?
         format.html { render :text => @notice_text }
         format.json { render :json=> {:stat => "fail", :message => @notice_text}.to_json , :callback => params[:callback]}
       end
     end
     
   end




  def metadata
    choose_layout_if_ajax
  end
#################################################
#MAPSERVER methods.
#Checks to see if mapscript is available, then redirects to cgi, or does it itself.
###############################################
  begin
    include Mapscript if require 'mapscript'
    @@mapscript_exists = true #YES, this means that all requests will go to cgi (seems quicker)
  rescue LoadError
    @@mapscript_exists = false #YES, this means that all requests will go to cgi (seems quicker)
  end


  def wms
    
    unless @@mapscript_exists
      mapserver_wms
    else
      begin
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

        mapsv = Mapscript::MapObj.new(File.join(RAILS_ROOT, '/db/maptemplates/wms.map'))
        projfile = File.join(RAILS_ROOT, '/lib/proj')
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
      rescue RuntimeError => e
        @e = e
        render :layout =>'application'
      end

    end
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


  ###################################
  #private
  ##################################

  private
#
# tile utility methods. calculates the bounding box for a given TMS tile.
# Based on http://www.maptiler.org/google-maps-coordinates-tile-bounds-projection/
# GDAL2Tiles, Google Summer of Code 2007 & 2008
# by  Klokan Petr Pridal
#
def get_tile_bbox(x,y,z)
  min_x, min_y = get_merc_coords(x * 256, y * 256, z)
  max_x, max_y = get_merc_coords( (x + 1) * 256, (y + 1) * 256, z )
  return "#{min_x},#{min_y},#{max_x},#{max_y}"
end

def get_merc_coords(x,y,z)
  resolution = (2 * Math::PI * 6378137 / 256) / (2 ** z)
  merc_x = (x * resolution -2 * Math::PI  * 6378137 / 2.0)
  merc_y = (y * resolution - 2 * Math::PI  * 6378137 / 2.0)
  return merc_x, merc_y
end

   def mapserver_wms
    #use Map.map_file_path so we don't have to do a db call
    status = params["STATUS"].to_s.downcase || "unwarped"
    styles = "&styles=" # required to stop mapserver being pedantic on older versions
     if status == "unwarped"
      mapserver_url = MAPSERVER_URL + '?map=' + Map.mapfile_path(params[:id])  + styles + "&layers=" + params[:id].to_s + "_original"
    else
      mapserver_url = MAPSERVER_URL + '?map=' + Map.mapfile_path(params[:id])  + styles + "&layers=" + params[:id].to_s
    end
    mapserver_url += "&"+request.query_string
    redirect_to(mapserver_url)
  end


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
    if logged_in? and (current_user.own_this_map?(params[:id])  or current_user.has_role?("editor"))
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
    if logged_in? and (current_user.own_this_map?(params[:id])  or current_user.has_role?("editor"))
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

     def rectify_main
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
      @too_few = false
      if @map.gcps.hard.size.nil? || @map.gcps.hard.size < 3
        @too_few = true
        @notice_text = "Sorry, the map needs at least three control points to be able to rectify it"
        @output = @notice_text
      elsif @map.status == :warping
        @fail = true
        @notice_text = "Sorry, the map is currently being rectified somewhere else, please try again later."
        @output = @notice_text
      else
        if logged_in?
           um  = current_user.my_maps.new(:map => @map)
           um.save

          # two ways of creating the relationship
          # @map.users << current_user
        end

        @output = @map.warp! transform_option, resample_option, use_mask #,masking_option
        @notice_text = "Map rectified."
      end
   end

  def store_location
    case request.parameters[:action]
    when "warp"
      anchor = "Rectify_tab"
    when "clip"
      anchor = "Crop_tab"
    when "align"
      anchor = "Align_tab"
    when "export"
      anchor = "Export_tab"
    else
      anchor = ""
  end
    if request.parameters[:action] &&  request.parameters[:id]
      session[:return_to] = map_path(:id => request.parameters[:id], :anchor => anchor)
    else
      session[:return_to] = request.request_uri
    end
  end


end
