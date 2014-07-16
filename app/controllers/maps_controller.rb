class MapsController < ApplicationController


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
  
   private
    def map_params
      params.require(:map).permit!
    end
  
end
