class GcpsController < ApplicationController
  layout 'application'
  #skip_before_filter :verify_authenticity_token, :only => [:update, :update_field, :add, :destroy, :show, :add_many, :add_many_to_map]

  before_filter :authenticate_user!, :only => [:update, :update_field, :add, :destroy, :add_many, :add_many_to_map]
  before_filter :check_editor_role, :only => [:add_many, :add_many_to_map, :bulk_import]
  before_filter :find_gcp, :only => [:show, :update,:update_field, :destroy ]
  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record

  def show
    respond_to do | format |
      format.json {render :json => {:stat => "ok", :items => @gcp.to_a}.to_json, :callback => params[:callback]  }
      format.xml  {render :xml => @gcp.to_xml}
    end

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
    @gcp_id = @gcp.id

    respond_to do |format|
      if @gcp.destroy
        @map.reload
        @gcps = @map.gcps_with_error
        format.js
        format.html { redirect_to_index }
        format.json { render :json => {:stat => "ok", :items => @gcps.to_a}.to_json(:methods => :error), :callback => params[:callback] }
        format.xml  {  render :xml => @gcps.to_xml(:methods => :error)}
        
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
  
  
  # Adds Many GCPS to Multiple Maps
  # ADMIN only
  # Expects a CSV file or a JSON strong
  #POST with mapid
  #csv header: mapid,x,y,lon,lat
  #json format: {"gcps":[{"mapid":26,"x":1.2,"y":2.2, "lat":11.1, "lon":21.1},{"mapid":1234,"x":1.2,"y":2.2, "lat":11.1, "lon":21.1}....
  #  curl -X POST http://localhost:3000/gcps/add_many.json -H "Content-Type: application/json" -d '{"gcps":[{"mapid":26,"x":1.2,"y":2.2},{"mapid":21,"x":1.2,"y":2.2}]}' --user email@example.com:pass
  #
  #curl -X POST http://localhost:3000/gcps/add_many.json -F "file=@gcps_many_maps.csv" --user email@example.com:pass
 #
  def add_many
    gcps = nil
    begin  
      if params[:file]
        gcps = Gcp.add_many_from_file(params[:file])
      elsif params[:gcps] && request.format == "json"
        gcps = Gcp.add_many_from_json(params[:gcps])
      end
      
    rescue ActiveRecord::RecordNotFound => e
      
      respond_to do | format |
        format.html do
          flash[:notice] = "Record not found. #{e.message}"
          redirect_to :bulk_import_gcps
        end
        format.json {render :json => {:stat => "record not found #{e.message}", :items =>[]}.to_json, :status => 404}
      end
      return false
    end
    respond_to do | format |
      format.html {render action: 'add_many', :locals => {:gcps => gcps} }
      format.json { render :json => {:stat => "ok", :items => gcps.to_a}.to_json(:methods => :error), :callback => params[:callback]}
    end
  end
  
  # Adds Many GCPS to A Specific Map
  # Any user
  # Expects a CSV file
  #curl -X POST http://localhost:3000/gcps/add_many/26.json --user email@example.com:pass -F "file=@gcps2.csv"
  #file csv
  #x,y,lon,lat,name
  #1.1,2.1,3.2,3.2
  #1.1,2.1,3.2,3.2,foo
  def add_many_to_map
    gcps = nil
    if params[:file] 
      gcps = Gcp.add_many_from_file(params[:file], params[:mapid])
    end
    
    redirect_to  map_path(:id => params[:mapid], :anchor => "Rectify_tab"), :notice => "GCPS saved"
  end
  
  def index
  end
  
  def bulk_import
    
  end

  private
  def find_gcp
    @gcp = Gcp.find(params[:id]) 
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
