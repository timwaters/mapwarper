class GcpController < ApplicationController
  layout 'application'
  skip_before_filter :verify_authenticity_token, :only => [:update, :update_field, :add, :destroy, :show]
  #before_filter :semi_verify_authenticity_token, :only => [:update, :update_field, :add, :destroy]

  #before_filter :login_or_oauth_required, :except => [:show, :index]
  before_filter :login_or_oauth_required, :only => [:custom, :update, :update_field, :add, :destroy]
  before_filter :find_gcp, :only => [:show, :update,:update_field, :destroy ]
  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record

  def show
    respond_to do | format |
      format.json {render :json => {:stat => "ok", :items => @gcp.to_a}.to_json, :callback => params[:callback]  }
      format.xml  {render :xml => @gcp.to_xml}
    end

  end

  def custom
    render :text => params[:id]
  end

  def update
     
    x = params[:x]
    y = params[:y]
    lon = params[:lon]
    lat = params[:lat]
    name = params[:name]
    soft = params[:soft]

    respond_to do |format |
    if @gcp.update_attributes(:x => x,:y => y, :lon => lon, :lat => lat, :name => name, :soft => soft)

      @map = @gcp.map
      @gcps = @map.gcps_with_error(params[:soft])

        format.js if request.xhr?
        format.html { redirect_to_index }
        format.json { render :json => {:stat => "ok", :items => @gcps.to_a}.to_json(:methods => :error) , :callback => params[:callback]}
        format.xml {render :xml => @gcps.to_xml(:methods => :error)}
    else

        format.json { render :json => {:stat => "fail", :message =>"Could not update GCP", :errors => @gcp.errors.to_a, :items => []}.to_json , :callback => params[:callback]}
        format.html {  redirect_to_index("points couldnt be updated")}
    end

  end


  end

  def update_field
    @map = @gcp.map
    attribute = params[:attribute]
    value = params[:value]

     respond_to do |format|
    if @gcp.update_attribute(attribute, value)
      @map = @gcp.map
      @gcps = @map.gcps_with_error(params[:soft])

      if request.xhr?
           format.js {render :action => 'update'}
      end
         format.html { redirect_to_index }
         format.json { render :json => {:stat => "ok", :items => @gcps.to_a}.to_json(:methods => :error), :callback => params[:callback] }
         format.xml {render :xml => @gcps.to_xml(:methods => :error)}

    else

         format.json { render :json => {:stat => "fail", :message =>"Could not update GCP", :errors => @gcp.errors.to_a, :items => []}.to_json , :callback => params[:callback]}
         format.html {redirect_to_index("Control point couldnt be updated")}
    end
     end

  end

  def destroy
    @map = @gcp.map
     respond_to do | format |
       if @gcp.destroy
       @map.reload
        @gcps = @map.gcps_with_error
         format.js if request.xhr?
         format.html { redirect_to_index }
         format.json { render :json => {:stat => "ok", :items => @gcps.to_a}.to_json(:methods => :error), :callback => params[:callback] }
         format.xml {render :xml => @gcps.to_xml(:methods => :error)}
    
       else
         format.json { render :json => {:stat => "fail", :message =>"Could not delete GCP", :errors => @gcp.errors.to_a, :items => []}.to_json, :callback => params[:callback] }
  end
     end


   end


  def add
    #logger.info params.inspect
    x = params[:x] || 0
    y = params[:y] || 0
    lat = params[:lat] || 0
    lon = params[:lon] || 0
    id = params[:mapid]
    name = params[:name]
    soft = params[:soft]

    if params[:mapid]
      @gcp = Gcp.new(:map_id=>params[:mapid].to_i, :x=>x, :y=>y, :lat=>lat, :lon=>lon, :name => name, :soft => soft)
    else
      @gcp = Gcp.new(:x=>x, :y=>y, :lat=>lat, :lon=>lon)
    end

    respond_to do | format |
      if @gcp.save
        @map = @gcp.map
        @gcps = @map.gcps_with_error(params[:soft])

        format.js if request.xhr?
        format.html { redirect_to_index }
        format.json { render :json => {:stat => "ok", :items => @gcps.to_a}.to_json(:methods => :error), :callback => params[:callback]}
        format.xml {render :xml => @gcps.to_xml(:methods => :error)}

      else
        format.json { render :json => {:stat => "fail", :message =>"Could not add GCP", :errors => @gcp.errors.to_a, :items => []}.to_json, :callback => params[:callback]}
      end
    end


  end

  def index
  end

  private
  def find_gcp
     @gcp = Gcp.find(params[:id]) 
  end

  #veries token but only for the html view, turned off for xml and json calls - these calls would need to be authenticated anyhow.
  def semi_verify_authenticity_token
    unless request.format.xml? || request.format.json?
      verify_authenticity_token
    end
  end

  #redirect helper method in case the request doesnt come from
  #ajax / prototype
  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => :index
  end
   
  def bad_record
    #logger.error("not found #{params[:id]}")
    respond_to do | format |
      format.html do
        flash.now[:notice] = "GCP not found"
        redirect_to :action => :index
      end
      format.json {render :json => {:stat => "not found", :items =>[]}.to_json, :status => 404}
    end
  end
end
