class MapsController < ApplicationController


  # GET /posts
  # GET /posts.json
  def index
    @maps = Map.all
  end

#  # GET /posts/1
#  # GET /posts/1.json
#  def show
#  end
#
#  # GET /posts/new
#  def new
#    @post = Post.new
#  end
#
#  # GET /posts/1/edit
#  def edit
#  end
#
#  # POST /posts
#  # POST /posts.json
#  def create
#    @post = Post.new(post_params)
#
#    respond_to do |format|
#      if @post.save
#        format.html { redirect_to @post, notice: 'Post was successfully created.' }
#        format.json { render :show, status: :created, location: @post }
#      else
#        format.html { render :new }
#        format.json { render json: @post.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # PATCH/PUT /posts/1
#  # PATCH/PUT /posts/1.json
#  def update
#    respond_to do |format|
#      if @post.update(post_params)
#        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
#        format.json { render :show, status: :ok, location: @post }
#      else
#        format.html { render :edit }
#        format.json { render json: @post.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /posts/1
#  # DELETE /posts/1.json
#  def destroy
#    @post.destroy
#    respond_to do |format|
#      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
#      format.json { head :no_content }
#    end
#  end
#  
#  require 'mapscript'
#  def wms
#        #status is additional query param to show the unwarped wms
#        status = params["STATUS"].to_s.downcase || "unwarped"
#        ows = Mapscript::OWSRequest.new
#        
#        ok_params = Hash.new
#        # params.each {|k,v| k.upcase! } frozen string error
#        params.each {|k,v| ok_params[k.upcase] = v }
#        [:request, :version, :transparency, :service, :srs, :width, :height, :bbox, :format, :srs].each do |key|
#          ows.setParameter(key.to_s, ok_params[key.to_s.upcase]) unless ok_params[key.to_s.upcase].nil?
#        end
#
#        ows.setParameter("VeRsIoN","1.1.1")
#        ows.setParameter("STYLES", "")
#        ows.setParameter("LAYERS", "image")
#        ows.setParameter("COVERAGE", "image")
#
#        mapsv = Mapscript::MapObj.new(File.join('/home/tim/work/warper/mapwarper/db/maptemplates/wms.map'))
#        projfile = File.join('/home/tim/work/warper/mapwarper/lib/proj')
#        mapsv.setConfigOption("PROJ_LIB", projfile)
#        #map.setProjection("init=epsg:900913")
#        mapsv.applyConfigOptions
#        mapsv.setMetaData("wms_onlineresource", "http://blah")
#
#        raster = Mapscript::LayerObj.new(mapsv)
#        raster.name = "image"
#        raster.type = Mapscript::MS_LAYER_RASTER
#
#        raster.data = "/home/tim/work/warper/mapwarper/public/mapimages/dst/135.tif"
#
#        raster.status = Mapscript::MS_ON
#        raster.dump = Mapscript::MS_TRUE
#        raster.metadata.set('wcs_formats', 'GEOTIFF')
#        raster.metadata.set('wms_title', "@map.title")
#        raster.metadata.set('wms_srs', 'EPSG:4326 EPSG:3857 EPSG:4269 EPSG:900913')
#        #raster.debug = Mapscript::MS_TRUE
#        raster.setProcessingKey("CLOSE_CONNECTION", "ALWAYS")
#
#        Mapscript::msIO_installStdoutToBuffer
#        result = mapsv.OWSDispatch(ows)
#        content_type = Mapscript::msIO_stripStdoutBufferContentType || "text/plain"
#        result_data = Mapscript::msIO_getStdoutBufferBytes
#
#        send_data result_data, :type => content_type, :disposition => "inline"
#        Mapscript::msIO_resetHandlers
#
#
#  end
#
#  private
#    # Use callbacks to share common setup or constraints between actions.
#    def set_post
#      @post = Post.find(params[:id])
#    end
#
#    # Never trust parameters from the scary internet, only allow the white list through.
#    def post_params
#      params.require(:post).permit(:title, :body)
#    end
end
