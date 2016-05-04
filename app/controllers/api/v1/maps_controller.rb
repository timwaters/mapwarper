class Api::V1::MapsController < Api::V1::ApiController
  #before_filter :authenticate_user!
  #before_filter :check_administrator_role
  #rescue_from ActionController::ParameterMissing, with: :missing_param_error
  #def missing_param_error
  #  puts "missing param error"
  #end
  
  def show
    @map = Map.find(params[:id])
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
    @map = Map.find(params[:id])
    if @map.update_attributes(map_params)
      render :json => @map
    else
      render :json => @map.errors, :status => :unprocessable_entity
    end
  end

  def destroy
    @map = Map.find(params[:id])
    if @map.destroy
      render :json => @map
    end
  end

  def gcps
    @map = Map.find(params[:id])
    render :json  => @map.gcps
  end

  def index
    #ActiveSupport.escape_html_entities_in_json = false
    paginate_params = {
      :page => 1,
      :per_page => 1
    }
    #& will be unicode encoded...oddly
    #puts paginate_params.to_query.to_json
    @maps = Map.all.paginate(paginate_params)
     
    render :json => @maps,:root => "foo", 
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
  


end
