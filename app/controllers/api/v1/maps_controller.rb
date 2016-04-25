class Api::V1::MapsController < Api::V1::ApiController
  #before_filter :authenticate_user!
  #before_filter :check_administrator_role
    
  def show
    @map = Map.find(params[:id])
    puts current_user.inspect
    render :json  => @map, :meta => {:foo => :bar}
  end

  def index
    ActiveSupport.escape_html_entities_in_json = false
    paginate_params = {
      :page => 1,
      :per_page => 1
    }
    @maps = Map.all.paginate(paginate_params)
    render :json => @maps
  end
  


end
