class MapsController < ApplicationController

  layout 'mapdetail', :only => [:show, :edit, :preview, :warp, :clip, :align, :activity, :warped, :export, :metadata, :comments]

  # GET /posts
  # GET /posts.json
  def index
    @maps = Map.all
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
    logger.debug params.inspect
    logger.debug params[:map].inspect
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
