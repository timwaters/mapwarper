class GcpController < ApplicationController
  layout 'application'
  before_filter :login_required, :except => [:show, :index]

   
  def show
    if Gcp.exists?(params[:id])
      @gcp = Gcp.find(params[:id])
      render :text => @gcp.inspect
    else
      render :text => "This ground control point does not exist anymore"
    end
  end



  def update
    @gcp = Gcp.find(params[:id])
    
    x = params[:x]
    y = params[:y]
    lon = params[:lon]
    lat = params[:lat]
    if @gcp.update_attributes(:x => x,:y => y, :lon => lon, :lat => lat)
      @map = @gcp.map
      @gcps = @map.gcps_with_error

      redirect_to_index unless request.xhr?
    else
      redirect_to_index("points couldnt be updated")
    end

  end

  def update_field
    @gcp = Gcp.find(params[:id])
    @map = @gcp.map
    attribute = params[:attribute]
    value = params[:value]

    if @gcp.update_attribute(attribute, value)
      # render :text => @gcp.send(attribute).to_s
      @map = @gcp.map
      @gcps = @map.gcps_with_error
      if request.xhr?
        render :action => 'update'
      else
        redirect_to_index
      end
      #       redirect_to_index unless request.xhr?
    else
      redirect_to_index("Control point couldnt be updated")
      # format.html { render :action => "edit" }
    end

  end

  def destroy
    @gcp = Gcp.find(params[:id])
    @map = @gcp.map
    
    @gcp.destroy
    @map.reload
    @gcps = @map.gcps_with_error
    
    redirect_to_index unless request.xhr?
  end


  def add
    #logger.info params.inspect
    x = params[:x] || 0
    y = params[:y] || 0
    lat = params[:lat] || 0
    lon = params[:lon] || 0
    id = params[:id]
    if params[:id]
      @gcp = Gcp.new(:map_id=>params[:id].to_i, :x=>x, :y=>y, :lat=>lat, :lon=>lon)
    else
      @gcp = Gcp.new(:x=>x, :y=>y, :lat=>lat, :lon=>lon)
    end

    #todo check this
    @gcp.save!
    @map = @gcp.map
    @gcps = @map.gcps_with_error

    redirect_to_index unless request.xhr?
  end
   
  def index
  end

  private
  #redirect helper method in case the request doesnt come from
  #ajax / prototype
  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => :index
  end
   
end
